class RemoveDirectoryPublicFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :directory_public
  end
end
