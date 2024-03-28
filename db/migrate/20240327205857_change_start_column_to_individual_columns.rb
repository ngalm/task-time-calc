class ChangeStartColumnToIndividualColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :start_hr, :integer
    add_column :tasks, :start_min, :integer
    add_column :tasks, :start_ampm, :string

    remove_column :tasks, :start
  end
end
