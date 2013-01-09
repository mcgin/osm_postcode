class OSMNode
  attr_accessor :id, :latitude, :longitude
  def initialize(id, latitude, longitude)
    # Instance variables
    @id = id
    @longitude = longitude
    @latitude = latitude
  end

end