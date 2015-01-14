class NoSql < ActiveRecord::Base

  validates_uniqueness_of   :key
  validates_presence_of     :key, :value

  def to_s
    self.value
  end

end
