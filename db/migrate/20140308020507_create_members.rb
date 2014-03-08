class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :first_name
      t.string :last_name
      t.string :preferred_name
      t.string :street_address
      t.string :city
      t.string :state
      t.integer :postal_code
      t.string :email
      t.string :mobile_phone
      t.string :home_phone
      t.string :work_phone
      t.integer :primary_phone
      t.date :birthday
      t.integer :family_id
      t.integer :spouse_id
      t.boolean :directory_public

      t.timestamps
    end
  end
end
