class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.string :to
      t.string :from
      t.text :message
      t.string :type

      t.timestamps
    end
    add_index :messages, :to
    add_index :messages, :from
    add_index :messages, :message
    add_index :messages, :type
  end
end
