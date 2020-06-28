class AddSupa3AndSupa5SegmentsToGamers < ActiveRecord::Migration[5.2]
  def change
    add_column :gamers, :supa3_segment, :string
    add_column :gamers, :supa5_segment, :string
  end
end
