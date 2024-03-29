class Task < ActiveRecord::Base
    validates :name, :presence => true

    validates :duration, :presence => true

    validates :start_hr, :presence => true
    validates :start_min, :presence => true
    validates :start_ampm, :presence => true
end