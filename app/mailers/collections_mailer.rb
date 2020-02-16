class CollectionsMailer < ApplicationMailer
   default from: "BetCity <noreply@supa3.info>"
	# default to: ["Okello Hassan <okello@betcity.co.ug>", "Jamal Sultan <jamal@betcity.co.ug>"]
   default to: ["Okello Hassan <acaciabengo@gmail.com>"]

	def daily_report(csv)
		attachments["Collections Report - #{Date.yesterday.strftime('%d/%m/%Y')}"] = {mime_type: 'text/csv', content: csv}
		mail subject: "Collections Report for #{Date.yesterday.strftime('%d/%m/%Y')}"
	end
end
