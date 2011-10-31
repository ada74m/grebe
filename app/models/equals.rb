class Equals < Criterion
  validates_presence_of :model, :property

  def description
    if negative_intrinisically_or_by_toggle?()
      "#{model}.#{property} does not equal #{integer_a}"
    else
      "#{model}.#{property} equals #{integer_a}"
    end
  end


end
