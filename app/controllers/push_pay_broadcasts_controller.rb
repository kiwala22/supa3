class PushPayBroadcastsController < ApplicationController
   before_action :authenticate_user!
   load_and_authorize_resource


   require "roo"
   require "csv"

   def index
      @q = PushPayBroadcast.all.ransack(push_pay_broadcast_params[:q])
      @push_pay_broadcasts = @q.result.order("created_at DESC").page push_pay_broadcast_params[:page]
      @search_params = params[:q]

   end

   def new


   end

   def create

      if push_pay_broadcast_params[:list]
         message_content = push_pay_broadcast_params[:message]
         amount =  1000
         spreadsheet = open_spreadsheet(push_pay_broadcast_params[:list])
         (2..spreadsheet.last_row).each do |i|
            #push to worker after create
            broadcast = PushPayBroadcast.create(spreadsheet.cell(i, 'A'), amount: 1000, status: "PENDING"})
            PushPayBroadcastWorker.perform_async(broadcast.id)

         end
         flash.now[:notice] = "Payments Successfully Added"
         redirect_to :action => :index
      else
         flash.now[:error] =  "Please attach the file"
         render action: 'new'
      end
   end

   private

   def open_spreadsheet(file)
      case File.extname(file.original_filename)
      when ".csv" then Csv.new(file.path, nil, :ignore)
      when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{file.original_filename}"
      end
   end

   def unknown_file_type
      flash[:alert] = "Unknown file type"
      render action: 'new'
   end

   def push_pay_broadcast_params
      params.permit(:list, :approved_by, :page ,q: [:phone_number_eq] )
   end

end
