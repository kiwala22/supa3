class PaymentsController < ApplicationController
   before_action :authenticate_user!
   load_and_authorize_resource

   require "roo"
   require "csv"

   def index
      @q = Payment.all.ransack(payment_params[:q])
      @payments = @q.result.order("created_at DESC").page payment_params[:page]
      @search_params = params[:q]

   end

   def create

      if payment_params[:list]
         spreadsheet = open_spreadsheet(payment_params[:list])
         (2..spreadsheet.last_row).each do |i|
            Payment.create({first_name: spreadsheet.cell(i, 'A'), last_name: spreadsheet.cell(i, 'B'), phone_number: spreadsheet.cell(i, 'C'), amount: spreadsheet.cell(i, 'D'), status: "PENDING", initiated_by: @current_user.id })
         end
         flash.now[:notice] = "Payments Successfully Added"
         redirect_to :action => :index
      else
         flash.now[:error] =  "Please attach the file"
         render action: 'new'
      end
   end

   def new

   end

   def update
      @payment = Payment.find(params[:id])
      if @payment
         @payment.update_attributes(approved_by: payment_params[:approved_by], status: "PROCESSING")
         PaymentWorker.perform_async(@payment.id, @payment.amount)
         #after calling the payments worker use js to rerender the same page
         respond_to do |format|
           flash.now[:notice] = "Payment processing..."
           format.html
           format.json
           format.js  { render :layout => false }
         end
      end
   end

##CANCEL PAYMENT WITH ERROR
   def cancel_payment
     @payment = Payment.find(params[:id])
     if @payment
        @payment.update_attributes(approved_by: payment_params[:approved_by], status: "CANCELLED")
        #after cancelling the payment use js to rerender the same page
        respond_to do |format|
          flash.now[:notice] = "Payment cancelled..."
          format.html
          format.json
          format.js  { render :layout => false }
        end
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

   def payment_params
      params.permit(:list, :approved_by, :page ,q: [:phone_number_eq] )
   end

end
