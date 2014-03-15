class AddMemberFieldsToUser < ActiveRecord::Migration
  def change
    remove_column :users, :name

    add_column :users, :first_name, :string,
    add_column :users, :last_name, :string,
    add_column :users, :preferred_name, :string,
    add_column :users, :street_address, :string,
    add_column :users, :city, :string,
    add_column :users, :state, :string,
    add_column :users, :postal_code, :integer,
    add_column :users, :mobile_phone, :integer,
    add_column :users, :home_phone, :integer,
    add_column :users, :work_phone, :integer,
    add_column :users, :primary_phone, :integer, default: 0
    add_column :users, :birthday, :date,
    add_column :users, :family_id, :integer,
    add_column :users, :spouse_id, :integer,
    add_column :users, :directory_public, :boolean, default: false

    add_index  :users, :first_name,
    add_index  :users, :last_name,
    add_index  :users, :preferred_name,
    add_index  :users, :family_id,
    add_index  :users, :spouse_id
  end
end
