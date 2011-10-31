class Criterion < ActiveRecord::Base

  belongs_to :parent, :class_name => 'Criterion'

  def toggle_negativity
     @toggled = !@toggled
  end

  def negative_intrinisically_or_by_toggle?
    negative? || (!negative? && @toggled)
  end


end





