ActiveAdmin.register AccessUser do
  permit_params :first_name, :last_name

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :token
    column :created_at
    actions
  end

  filter :first_name
  filter :last_name
  filter :created_at

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
    end
    f.actions
  end

end
