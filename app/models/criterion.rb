class Criterion < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Criterion'
end

class CompositeCriterion < Criterion
  has_many :children,
           :class_name => 'Criterion',
           :before_add => [Proc.new { |a, b| b.parent = a }]

  def description
    connector = " #{self.class.name.downcase} "
    child_descriptions = (children.map { |c| c.description }).join connector

    if children.length > 1
      "(#{child_descriptions})"
    else
      child_descriptions
    end

  end

end

class And < CompositeCriterion
end

class Or < CompositeCriterion
end


class Equals < Criterion
  validates_presence_of :model, :property

  def description
    "#{model}.#{property} equals #{integer_a}"
  end

end

