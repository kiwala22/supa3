class ChangeColumnTypeSmstypeInMessages < ActiveRecord::Migration[5.2]
  def change
    rename_column :messages, :type, :sms_type
  end
end
