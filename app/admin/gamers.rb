ActiveAdmin.register Gamer do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
filter :phone_number
#filter :probability, as: :numeric_range
filter :segment
filter :predicted_revenue, as: :numeric_range
filter :created_at
filter :updated_at
end
