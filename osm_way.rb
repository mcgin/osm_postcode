class OSMWay
  attr_accessor :id, :nodes, :tags

  def initialize(id, nodes, tags)
    # Instance variables
    @id = id
    @nodes = nodes
    @tags = tags
  end

  def closed?
    nodes.first.id == nodes.last.id
  end


end