class OSMWay
  attr_accessor :id, :nodes, :tags, :xml

  def initialize(id, nodes, tags, version, xml)
    # Instance variables
    @id = id
    @nodes = nodes
    @tags = tags
    @version = version
    @xml = xml
  end

  def closed?
    begin
      nodes.first.id == nodes.last.id
    rescue
      false
    end
  end


end