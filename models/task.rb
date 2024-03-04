class Task < ActiveRecord::Base
    validates :name, :presence => true

    validates :duration, :presence => true

    validates :start, :presence => true,
                      :uniqueness => true
end