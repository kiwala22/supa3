ActiveAdmin.register User do
permit_params :email, :password, :password_confirmation, :first_name, :last_name, :admin, :role

    index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    column :admin do |user|
      user.admin ? "Yes" : "No"
    end
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :role
    actions
    end

    filter :email
    filter :current_sign_in_at
    filter :sign_in_count
    filter :created_at

    form do |f|
    f.inputs "User Details" do
        f.input :email
        f.input :first_name
        f.input :last_name
        f.input :password
        f.input :password_confirmation, label: 'Confirmation'
        f.input :admin, as: :boolean
        f.input :role
    end
    f.actions
    end

end
