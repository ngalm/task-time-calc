class Central_Time < ActiveRecord::Base
    validates :central_time_hr, :presence => true
    validates :central_time_min, :presence => true
    validates :central_time_ampm, :presence => true
end