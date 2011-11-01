class Equals < Criterion
  validates_presence_of :model, :property

  def description
    if negative?()
      "#{model}.#{property} does not equal #{integer_a}"
    else
      "#{model}.#{property} equals #{integer_a}"
    end
  end

end
