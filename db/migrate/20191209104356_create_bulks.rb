class CreateBulks < ActiveRecord::Migration[5.2]
  def change
    create_table :bulks do |t|
      t.string :phone_number
      t.datetime :time

      t.timestamps
    end
  end
end
