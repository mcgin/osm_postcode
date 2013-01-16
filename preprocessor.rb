require './util.rb'
  # Used to preprocess the ONS data to remove
  #   Any postcodes that map to the same point as another
  #   Any postcoeds with positional quality not set to "Building" level
  #postcodes = Util.loadAllPostcodes("input/ONS1000.txt")
  postcodes = Util.loadAllPostcodes("input/ONSPD_NOV_2012_UK_O.txt")

  count = Hash.new

  postcodes.each do |k,v|
    coords= v["osnrth1m"].to_s+v["oseast1m"].to_s
    count[coords] = count[coords] ? count[coords].push(k) : Array[ k ]
  end

  out=File.open("input/preprocessed.txt", "w")


  count.each do |k,v|
    if (postcodes[v[0]]["doterm"].size==0 && postcodes[v[0]]["osgrdind"].to_i==1) then
      out.write postcodes[v[0]]["complete"] if v.size==1
    end
    #out.write(postcodes[v[0]]+"\n") unless v.size>1
  end
  out.flush
  out.close
