class CreateFamilies < ActiveRecord::Migration
  def change
    create_table :families do |t|
      t.integer :head_id
      t.date :anniversary

      t.timestamps
    end
  end
end
