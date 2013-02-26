require './util'
# Used to preprocess the ONS data to remove
#   Any postcodes that map to the same point as another
#   Any postcodes with positional quality not set to "Building" level
#postcodes = Util.loadAllPostcodes("input/ONS10000.txt") do |postcode|
postcodes = Util.loadAllPostcodes(ARGV[0]) do |postcode|
  #What to filter - postcodes with a date of termination and postcodes with less than perfect accuracy
  postcode["doterm"].size>0 || postcode["osgrdind"].to_i!=1
end

count = Hash.new

puts postcodes.size

postcodes.each do |k,v|
  coords= v["osnrth1m"].to_s+v["oseast1m"].to_s
  count[coords] = count[coords] ? count[coords].push(k) : Array[ k ]
end

puts count.size

count.each do |k,v|
  if v.size>1 then
    v.each do |code|
      postcodes.delete(code)
    end
  end
  #out.write postcodes[v[0]]["complete"] if v.size==1
end

count=nil



puts postcodes.size

out=File.open(ARGV[0]+"_processed.txt", "w")

Util.copyPostcodes(File.new(ARGV[0]), out, postcodes )



out.flush
out.close
