class Criterion < ActiveRecord::Base

  belongs_to :parent, :class_name => 'Criterion'

  def toggle_negativity
     @toggled = !@toggled
  end

  def push_down_negativity

  end

  def negative_intrinisically_or_by_toggle?
    if @toggled
      !negative?
    else
      negative?
    end
  end

end
