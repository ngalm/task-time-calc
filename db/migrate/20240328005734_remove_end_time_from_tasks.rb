class RemoveEndTimeFromTasks < ActiveRecord::Migration[7.1]
  def change
    remove_column :tasks, :end_time
  end
end
