class OSMWay
  attr_accessor :id, :nodes, :tags
  def initialize(id, nodes, tags)
    # Instance variables
    @id = id
    @nodes = nodes
    @tags = tags
  end

  def closed?
    #nodes.first == nodes.last
    true
  end


end