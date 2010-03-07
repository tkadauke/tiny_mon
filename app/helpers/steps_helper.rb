module StepsHelper
  def render_step_form(form, step)
    return if step.class == Step
    
    render :partial => "/steps/#{step.class.name.underscore}_form", :locals => { :f => form }
  end
  
  def render_step_details(step)
    render :partial => "/steps/#{step.class.name.underscore}", :locals => { :step => step }
  end
end
