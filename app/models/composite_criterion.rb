class CompositeCriterion < Criterion
  has_many :children,
           :class_name => 'Criterion',
           :before_add => [Proc.new { |a, b| b.parent = a }]



  def self.or(options = {})
    CompositeCriterion.new options.merge :operator => 'or'
  end


  def self.and(options = {})
    CompositeCriterion.new options.merge :operator => 'and'
  end


  def translate_to_or_from_negative_form

    toggle_negativity
    toggle_operator
    children.each { |child| child.toggle_negativity }

  end

  def description
    child_descriptions = (children.map { |c| c.description }).join " #{operator} "

    negator = negative? ? "not " : ""
    need_brackets = negative? || children.length > 1

    (need_brackets) ?
      "#{negator}(#{child_descriptions})" :
      "#{negator}#{child_descriptions}"

  end

  def push_down_negativity
    translate_to_or_from_negative_form if (negative?)
    composite_children().each {|child| child.push_down_negativity }
  end

  private

  def toggle_operator
    if (operator == 'and')
      self.operator = 'or'
    else
      self.operator = 'and'
    end
  end

  def composite_children
    children.
        select { |child| child.kind_of? CompositeCriterion }
  end



end
