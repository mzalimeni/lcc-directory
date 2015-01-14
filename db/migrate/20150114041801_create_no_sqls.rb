class CreateNoSqls < ActiveRecord::Migration
  def change
    create_table :no_sqls do |t|
      t.string :key
      t.string :value

      t.timestamps
    end
    add_index :no_sqls, :key
  end
end
