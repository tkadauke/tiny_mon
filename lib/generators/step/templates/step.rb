class <%= class_name %>Step < Step
<% unless attributes.empty? -%>
<% for attribute in attributes -%>
  property :<%= attribute.name %>, :<%= attribute.type %>
<% end -%>
  
<% end -%>
  def run!(session, check_run)
  end
end
