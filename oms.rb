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
  XPath.each(xmldoc, "/osm/way[not(tag/@k='landuse' or tag/@k='highway')]") do |w|

    way = parseWay(w, nodes)

    if way.closed? then
      closedWays.push(way)
    end
  end
  closedWays
end


def getPostCodesInRegion(n, s, e, w)
  #retrieveData(latlon_north_west[:latitude], latlon_south_east[:latitude],
  ##latlon_north_west[:longitude], latlon_south_east[:longitude])
  @postcodes = loadAllPostcodes if @postcodes.nil?
  postcodes_in_region = Hash.new
  @postcodes.each do |k,v|
    if (v[4]<n && v[4]>s && v[3]<e && v[3]>w) then
      postcodes_in_region[k]=v
    end
  end
  postcodes_in_region
end

def convertWayToPolygon(way)
  points = []
  #puts way.id
  way.nodes.each do |node|
    #puts node
    #puts "\t"+node.id+"\t"+node.longitude+"\t"+node.latitude
    begin
      points.push Point.new(node.longitude.to_f, node.latitude.to_f)
    rescue
      puts "Error with way - "+ way.id
    end
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

def retrieveData (n, s, e, w)
  #@host = 'overpass-api.de'
  host = '127.0.0.1'
  post_ws = "/api/interpreter"


  payload ="<query type='way'>"
  payload +="<bbox-query n='#{n}' e='#{e}' s='#{s}' w='#{w}'/>"
  #@payload +="<bbox-query e='-0.27465160236912756' n='51.48671422247037' s='51.481714222470366' w='-0.27965160236912756'/>"
  payload +="</query>"
  payload +="<union into='foo'>"
  payload +="<item/>"
  payload +="	<recurse into='foo' type='way-node'/>"
  payload +="</union>"
  payload +="<print from='foo'/>"
  puts payload
  req = Net::HTTP::Post.new(post_ws, initheader = {'Content-Type' => 'application/json', 'data' => payload})


  req.body = payload

  response = Net::HTTP.new(host).start { |http| http.request(req) }

  #puts response.body
  Document.new(response.body)
end

class OSM
  # To change this template use File | Settings | File Templates.
  filename = "xae"
  file = File.new("/Users/Aidan/dev/workspace/"+filename, "r")
  #output = File.open(filename+".txt", 'w')

  os_increment = 2500;
  easting_limit = 700000;
  northing_limit = 1200000;
  easting_limit = 700000;
  northing_limit = 1200000;

  modifier = 1.0
  easting = 250000;
  while easting<easting_limit do
    northing = 50000;
    while northing<northing_limit
      puts easting.to_s + "\t" + northing.to_s

      n=northing+os_increment
      s=northing
      w=easting
      e=easting+os_increment

      postcodes_in_region = getPostCodesInRegion(n, s, e, w)
      #Fix this so the counter increments
      #next if postcodes_in_region.size==0;
      puts "There is #{postcodes_in_region.size} postcodes in the region " + Time.now.to_s

      latlon_south_w = OSGB36.en_to_ll(w, s)
      latlon_north_e = OSGB36.en_to_ll(e, n)
      puts "Going to overpass " + Time.now.to_s
      xml_document = retrieveData(latlon_north_e[:latitude], latlon_south_w[:latitude], latlon_north_e[:longitude], latlon_south_w[:longitude])
      puts "Got overpass response " + Time.now.to_s
      the_nodes=parseNodes xml_document
      puts "Parsed #{the_nodes.size} nodes " + Time.now.to_s

      closed_ways_in_region = getClosedWays(xml_document, the_nodes)
      puts "Parsed #{closed_ways_in_region.size} closed ways " + Time.now.to_s


      regionfile = File.open("output/"+s.to_s+"-"+w.to_s+"-"+n.to_s+"-"+e.to_s+".txt", "w")
      postcodes_in_region.each do |pc, pc_data|
        #pc_data[3]#easting
        #pc_data[3]#northing
        latlon = OSGB36.en_to_ll(pc_data[3], pc_data[4])
        #puts(pc)
        regionfile.write(pc)
        closed_ways_in_region.each do |way|
          # Is lat/lon inside this way
          polygon = convertWayToPolygon(way)
          if (polygon.contains?(Point(latlon[:longitude].to_f, latlon[:latitude].to_f))) then
            regionfile.write("\t"+way.id)
          end

        end
        regionfile.write("\n")

      end
      #modifier*= 0.5 if ( (closed_ways_in_region.size*postcodes_in_region.size)>50000 )
      #modifier*= 1.25 if ( (closed_ways_in_region.size*postcodes_in_region.size)<10000 )
      puts "Modifier is #{modifier}"
      regionfile.flush
      regionfile.close
      northing+=(os_increment*modifier);
    end
    easting+=os_increment;
  end

end
