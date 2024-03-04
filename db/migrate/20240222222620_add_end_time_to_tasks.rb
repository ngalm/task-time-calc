class AddEndTimeToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :end_time, :datetime
  end
end
