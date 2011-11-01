class Criterion < ActiveRecord::Base

  belongs_to :parent, :class_name => 'Criterion'

end
