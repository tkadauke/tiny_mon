class CheckRunGraph
  def initialize(runs)
    @runs = runs
  end
  
  def render
    g = Gruff::Line.new
    g.title = "Check runs"
    g.data("Run time", @runs.collect { |run| run.duration })
    g.to_blob
  end
end
