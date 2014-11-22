class RemovePrimaryPhoneFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :primary_phone, :integer
  end
end
