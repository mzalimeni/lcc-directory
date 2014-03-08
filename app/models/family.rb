class Family < ActiveRecord::Base
  has_many :members
  validates :head_id, presence: true
end
