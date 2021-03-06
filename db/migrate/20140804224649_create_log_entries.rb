class CreateLogEntries < ActiveRecord::Migration
  def change
    create_table :log_entries do |t|
      t.integer :charge_id
      t.text :message
      t.timestamps
    end

    add_index :log_entries, :charge_id
  end
end
