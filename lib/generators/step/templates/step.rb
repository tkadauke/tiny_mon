class <%= class_name %>Step < Step
<% for attribute in attributes -%>
  property :<%= attribute.name %>, :<%= attribute.type %>
<% end -%>
  
  def run!(session, check_run)
  end
end
