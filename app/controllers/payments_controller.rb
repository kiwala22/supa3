class PaymentsController < ApplicationController
   before_action :authenticate_user!
   load_and_authorize_resource

   require "roo"
   require "csv"

   def index
      @q = Payment.all.ransack(params[:q])
      @payments = @q.result.order("created_at DESC").page params[:page]
      @search_params = params[:q]

   end

   def create

      if payment_params[:list]
         spreadsheet = open_spreadsheet(payment_params[:list])
         (2..spreadsheet.last_row).each do |i|
            Payment.create({first_name: spreadsheet.cell(i, 'A'), last_name: spreadsheet.cell(i, 'B'), phone_number: spreadsheet.cell(i, 'C'), amount: spreadsheet.cell(i, 'D'), status: "PENDING", initiated_by: @current_user.id })
         end
         flash.now[:notie] = "Payments Successfully Added"
         render action: 'index'
      else
         flash.now[:error] =  "Please attach the file"
         render action: 'new'
      end
   end

   def new

   end

   def update

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

   def payment_params
      params.permit(:list, :q, :page)
   end

end