class CompositeCriterion < Criterion
  has_many :children,
           :class_name => 'Criterion',
           :foreign_key => 'parent_id',
           :before_add => [Proc.new { |a, b| b.parent = a }]

  before_save :on_before_save, :if => :top_level?
  after_save :on_after_save, :if => :top_level?
  after_find :on_after_find, :if => :top_level?

  def self.or(options = {})
    CompositeCriterion.new options.merge :operator => 'or'
  end

  def self.and(options = {})
    CompositeCriterion.new options.merge :operator => 'and'
  end

  def description
    child_descriptions = (children.map { |c| c.description }).join " #{operator} "

    negator = negative? ? "not " : ""
    need_brackets = negative? || children.length > 1

    (need_brackets) ?
      "#{negator}(#{child_descriptions})" :
      "#{negator}#{child_descriptions}"
  end

  def normal?
    return false if negative?
    composite_children.all? { |child| child.normal? }
  end

  def normalise
    translate_to_or_from_negative_form if (negative?)
    composite_children.each {|child| child.normalise }
  end

  def restore
    translate_to_or_from_negative_form if (toggled?)
    composite_children.each {|child| child.restore }
  end

  def translate_to_or_from_negative_form
    toggle_negativity
    toggle_operator
    children.each { |child| child.toggle_negativity }
  end

  private

  def top_level?
    parent.nil?
  end

  def on_before_save
    normalise
  end

  def on_after_save
    restore
  end

  def on_after_find
    puts "######## loaded a top level criterion: #{self.description}"
    restore
  end

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
