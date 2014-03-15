class ChangePhoneFieldsToString < ActiveRecord::Migration
  def change
    change_column :users, :mobile_phone, :string
    change_column :users, :home_phone, :string
    change_column :users, :work_phone, :string
  end
end
