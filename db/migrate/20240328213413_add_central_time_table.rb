class AddCentralTimeTable < ActiveRecord::Migration[7.1]
  def change
      create_table :central_times do |t|
        t.integer :central_time_hr
        t.integer :central_time_min
        t.string :central_time_ampm
      end
    end
end
