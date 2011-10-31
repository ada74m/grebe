class Or < CompositeCriterion


  protected

  def connector
    @toggled ? "and" : "or"
  end

end
