class NotifierMailer < ApplicationMailer

  require 'rubygems'
  require 'zip'

  def figures_email

    folder = "/tmp"
    input_filenames = ["collections-#{(Date.today - 7.days).strftime('%d-%m-%Y')}-#{(Date.yesterday.strftime('%d-%m-%Y'))}.csv", "disbursements-#{(Date.today - 7.days).strftime('%d-%m-%Y')}-#{(Date.yesterday.strftime('%d-%m-%Y'))}.csv"]

    zipfile_name = "/tmp/figures-#{(Date.today - 7.days).strftime('%d-%m-%Y')}-#{(Date.yesterday.strftime('%d-%m-%Y'))}.zip"

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(filename, File.join(folder, filename))
      end
      zipfile.get_output_stream("ReadMe-#{Date.today}.txt") { |f| f.write "Just use the 2 files attached with this." }
    end

    attachments['figures.zip'] = zipfile_name
    emails = 'bkayaga@skylinesms.com, mkiwala@skylinesms.com'
    mail(to: emails, subject: "Weekly BetCity GGR Figures", from: "do-not-reply@skylinesms.com", body: "Hello, Attached are the weekly GGR figures for BetCity.")
  end
end
