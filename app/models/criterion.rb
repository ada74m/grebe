class Criterion < ActiveRecord::Base
end


class Equals < Criterion

  validates_presence_of :model, :property


end