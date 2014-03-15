class Family < ActiveRecord::Base
  has_many :users
  validates :head_id, presence: true
end
