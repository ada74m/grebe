class Criterion < ActiveRecord::Base

  belongs_to :parent, :class_name => 'Criterion'

  protected

  def toggle_negativity
    self.negative = !negative?
    self.toggled = !toggled?
  end

end
