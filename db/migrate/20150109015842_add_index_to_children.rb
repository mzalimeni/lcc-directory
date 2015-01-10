class AddIndexToChildren < ActiveRecord::Migration
  def change
    add_index  :children, :first_name
    add_index  :children, :last_name
    add_index  :children, :preferred_name
    add_index  :children, :family_id
  end
end
