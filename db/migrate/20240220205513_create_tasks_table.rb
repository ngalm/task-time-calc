class CreateTasksTable < ActiveRecord::Migration[7.1]
  def change
      create_table :tasks do |t|
        t.string :name
        t.string :notes
        t.integer :duration
        t.datetime :start
        
        t.timestamps
    end
  end
end
