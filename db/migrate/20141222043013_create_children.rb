class CreateChildren < ActiveRecord::Migration
  def change
    create_table :children do |t|
      t.string :first_name
      t.string :last_name
      t.string :preferred_name
      t.date :birthday
      t.integer :family_id

      t.timestamps
    end
  end
end
