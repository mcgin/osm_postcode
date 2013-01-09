require 'net/http'
require './osgb36.rb'
require './osm_way.rb'
require './osm_node.rb'
require 'rexml/document'
require 'geometry'
include REXML
include Geometry

class Array
  def clip n=1
    take size - n
  end
end

def getClosedWays(xmldoc, nodes)
  closedWays = []
  XPath.each(xmldoc, "//way") do |w|
    way = parseWay(w, nodes)
    if way.closed? then
      closedWays.push(way)
    end
  end
  closedWays
end

def convertWayToPolygon(way)
  points = []
  way.nodes.each do |node|
    points.push Point.new(node.longitude.to_f, node.latitude.to_f)
  end

  points = points.clip

  Polygon.new(points)
end

def parseNodes (xmldoc)

  nodes = Hash.new
  XPath.each(xmldoc, "/osm/node") do |nd|
    lat = nd.attributes["lat"]
    lng = nd.attributes["lon"]
    id = nd.attributes["id"]
    nodes[id] = OSMNode.new(id, lat, lng)
  end
  nodes
end

def parseWay(way_xml, all_nodes)
  #puts XPath.match(way_xml, '@id').to_s
  wayNodes = []
  #puts way_xml
  XPath.each(way_xml, "nd") do |nd|
    node_id = nd.attributes["ref"];

    wayNodes.push all_nodes[node_id]


  end
  wayTags = Hash.new

  XPath.each(way_xml, "tag") do |tag|
    wayTags[tag.attributes["k"]] = tag.attributes["v"]

  end

  newWay = OSMWay.new(way_xml.attributes["id"], wayNodes, wayTags)
end

class OSM
  # To change this template use File | Settings | File Templates.
  file = File.new("/Users/Aidan/dev/workspace/ONSPD_NOV_2012_UK_O.txt","r")
  #file = File.new("/Users/Aidan/dev/workspace/ONS_test.txt", "r")
  while (line = file.gets)
    pcd = line[0, 7]
    pcd2 = line[7, 8]

    dointr = line[23, 6]
    doterm = line[29, 6].strip


    oseast1m = line[63, 6].to_i
    osnrth1m = line[69, 7].to_i
    osgrdind = line[76, 1]

    offset = 0.005;

    latlon = OSGB36.en_to_ll(oseast1m, osnrth1m)

    #http://overpass-api.de/api/
    # POST data -
    # (way["highway"!~"."](latlon[:latitude],latlon[:longitude],latlon[:latitude]+offset,latlon[:longitude]+offset);<;);out;

    #To view
    if (doterm.size==0 && osgrdind.to_i==1 ) then

      @host = 'overpass-api.de'
      @post_ws = "/api/interpreter"

      #@payload =  "(way['highway'!~'.'](#{latlon[:latitude]},#{latlon[:longitude]},#{latlon[:latitude]+0.005},#{latlon[:longitude]+0.005});<;);out;"
      @payload = "(way['highway'!~'.']['landuse'!~'.'](#{latlon[:latitude]},#{latlon[:longitude]},#{latlon[:latitude]+0.005},#{latlon[:longitude]+0.005});node(w)->.x;<;);out;"
      #puts "http://overpass-api.de/api/convert?data=way['highway'!~'.'](#{latlon[:latitude]},#{latlon[:longitude]},#{latlon[:latitude]+offset},#{latlon[:longitude]+offset});(._;node(w););out;&target=openlayers&zoom=12&lat=50.72&lon=7.1"
      #puts @payload
      req = Net::HTTP::Post.new(@post_ws, initheader = {'Content-Type' => 'application/json', 'data' => @payload})

      req.body = @payload
      #xmldoc = Document.new(File.new("overpass"))

      response = Net::HTTP.new(@host).start {|http| http.request(req) }
      xmldoc = Document.new(response.body)

      #puts response.body
      #puts pcd +"\t"+pcd2+"\t"+dointr+"\t"+doterm+"\t"+latlon[:latitude].to_s+"\t"+latlon[:longitude].to_s

      all_the_nodes = parseNodes(xmldoc)

      ways = getClosedWays(xmldoc, all_the_nodes)

      ways.each do |way|
        # Is lat/lon inside this way
        polygon = convertWayToPolygon(way)
        if(polygon.contains?(Point(latlon[:longitude].to_f,latlon[:latitude].to_f))) then
          puts way.id+"\t"+pcd
        end

      end

    end
  end


  #TW94DU = 51.481714,-0.279652
  #51.481,-0.279

end
