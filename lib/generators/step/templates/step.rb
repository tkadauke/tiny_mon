class <%= class_name %>Step < Step
<% for attribute in attributes -%>
  property :<%= attribute.name %>, :<%= attribute.type %>
<% end -%>
  
  def run!(session)
  end
end
