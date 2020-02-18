class ReportsController < ApplicationController
   before_action :authenticate_user!, except: [:download_report]
   load_and_authorize_resource

   def index
      @reports = Report.all.order("created_at DESC").page params[:page]
   end

   def download_report
      report = Report.find(params[:report_id])
      send_file(
         report.file_path,
         filename: report.file_name,
         type: "application/csv"
      )
   end
end
