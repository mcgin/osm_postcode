require 'logger'
module Util
  extend self

  def loadAllPostcodes(filename = "ONS.txt")


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
        postcodes[pcd] = Hash.new
        postcodes[pcd]["pcd2"]=pcd2
        postcodes[pcd]["dointr"]=dointr
        postcodes[pcd]["doterm"]=doterm
        postcodes[pcd]["oseast1m"]=oseast1m
        postcodes[pcd]["osnrth1m"]=osnrth1m
        postcodes[pcd]["osgrdind"]=osgrdind
        postcodes[pcd]["complete"]=line
      #end

    end
    return postcodes
  end
end