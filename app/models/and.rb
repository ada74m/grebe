class And < CompositeCriterion

  protected

  def connector
    @toggled ? "or" : "and"
  end

end
