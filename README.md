Download the TXT version of the ONS postcode file from http://www.ons.gov.uk/ons/guide-method/geography/products/postcode-directories/-nspp-/index.html

Run the preprocessor with the txt file as input

    preprocessor input/ONSPD_FEB_2013_UK_O.txt

This is a memory intensive operation, if you face out of memory issues split the file in two (or more files), run through the preprocessor, join the two files and the run the preprocessor again, e.g.:

    split -l 1300000 input/ONSPD_FEB_2013_UK_O.txt input/FEB
    preprocessor.rb input/FEBaa
    preprocessor.rb input/FEBab
    cat input/FEBaa_processed.txt input/FEBab_processed.txt > input/combined
    preprocessor.rb input/combined

The main program takes the following as input:

    input file: e.g. input/combined_processed
    The Northing value for the south west corner of the bounding box to run in
    The Easting value for the south west corner of the bounding box to run in
    The Northing value for the north east corner of the bounding box to run in
    The Easting value for the north east corner of the bounding box to run in
    The northing increment - used to batch up requests to overpass - leave at 1000 if unsure
    The easting increment - used to batch up requests to overpass - leave at 1000 if unsure
    The overpass server to retrieve from

This example runs in an area in southwest london

    osm.rb "input/combined_processed" 518659 0169663 529831 0179224 1000 1000 localhost