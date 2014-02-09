class Family < ActiveRecord::Base

  has_one  :head, class: "User"
  has_many :users

end
