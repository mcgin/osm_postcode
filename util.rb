require 'logger'
module Util
  extend self
  #Can accept a method that takes the postcode hash as an arguemnt and filters it
  def loadAllPostcodes(filename = "ONS.txt", include_raw_data=false)


    #filename = "ONSPD_NOV_2012_UK_O.txt"
    file = File.new(filename, "r")
    postcodes=Hash.new
    while (line = file.gets)

      pcd = line[0, 7]
      pcd2 = line[7, 8]

      dointr = line[23, 6]
      doterm = line[29, 6].strip


      oseast1m = line[63, 6]
      osnrth1m = line[69, 7]
      osgrdind = line[76, 1]

      #latlon = OSGB36.en_to_ll(oseast1m, osnrth1m)
      #if (doterm.size==0 && osgrdind.to_i==1) then
      temp_pc = Hash.new
      temp_pc["pcd"]=pcd2
      temp_pc["pcd2"]=pcd2
      temp_pc["dointr"]=dointr
      temp_pc["doterm"]=doterm
      temp_pc["oseast1m"]=oseast1m
      temp_pc["osnrth1m"]=osnrth1m
      temp_pc["osgrdind"]=osgrdind
      temp_pc["complete"]=line if include_raw_data
      #end
      postcodes[pcd] = temp_pc  unless  (block_given? ? filter = yield(temp_pc) : false)


    end
    file.close
    return postcodes
  end

  def copyPostcodes(filein, fileout, postcode_hash)
    #filename = "ONSPD_NOV_2012_UK_O.txt"
    while (line = filein.gets)
      fileout.write(line) if postcode_hash.has_key?(line[0, 7])
      #puts line
    end
  end
end