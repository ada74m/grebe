class CompositeCriterion < Criterion
  has_many :children,
           :class_name => 'Criterion',
           :before_add => [Proc.new { |a, b| b.parent = a }]


  def toggle_negativity
    super
    children.each { |child| child.toggle_negativity }
  end


  def description
    child_descriptions = (children.map { |c| c.description }).join " #{connector} "

    negator = negative_intrinisically_or_by_toggle? ? "not " : ""
    need_brackets = negative? || children.length > 1

    (need_brackets) ?
      "#{negator}(#{child_descriptions})" :
      "#{negator}#{child_descriptions}"

  end



end
