class AddDisbursementReferenceToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :disbursement_reference, :string
  end
end
