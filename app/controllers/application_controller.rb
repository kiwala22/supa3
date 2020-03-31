class ApplicationController < ActionController::Base
   before_action :set_raven_context
   rescue_from CanCan::AccessDenied do |exception|
      respond_to do |format|
         format.json { head :forbidden, content_type: 'text/html' }
         format.html { redirect_to main_app.root_url, alert: exception.message }
         format.js   { head :forbidden, content_type: 'text/html' }
      end
   end

   private

   def set_raven_context
      Raven.user_context(id: session[:current_user_id]) # or anything else in session
      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
   end
end
