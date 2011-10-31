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

    negator = negative? ? "not " : ""
    need_brackets = negative? || children.length > 1

    (need_brackets) ?
      "#{negator}(#{child_descriptions})" :
      "#{negator}#{child_descriptions}"

  end

end

class And < CompositeCriterion
end

class Or < CompositeCriterion
end


class Equals < Criterion
  validates_presence_of :model, :property

  def description
    if negative?
      "#{model}.#{property} does not equal #{integer_a}"
    else
      "#{model}.#{property} equals #{integer_a}"
    end
  end

end

