class CheckRunGraph
  def initialize(runs)
    @runs = runs
  end
  
  def render
    g = Gruff::Line.new
    g.title = "Check runs"
    g.data("Run time", @runs.collect { |run| run.duration }) if @runs.size > 1
    g.minimum_value = 0
    g.to_blob
  end
end
