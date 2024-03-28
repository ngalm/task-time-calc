class ChangeStartColumnToInteger < ActiveRecord::Migration[7.1]
  def change
    change_column :tasks, :start, :integer
  end
end
