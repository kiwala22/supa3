class AddSupa3AndSupa5SegmentsToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :supa3_segment, :string
    add_column :tickets, :supa5_segment, :string
  end
end
