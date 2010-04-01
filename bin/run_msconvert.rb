#!/opt/local/bin/ruby

#########################################
##
#    wrapper for msconvert
#    converts mzML or mzXML to mgf based on the folling args:
#    --input_files='file1,file2'
#   
#    
#

require 'rubygems'
require 'optparse'
 
#tandem command 
MSCONVERT_CMD = '/opt/pwiz/msconvert'

#lets get input files and taxon from command line
options = {}

require 'optparse'

 options = {}
 OptionParser.new do |opts|
   opts.banner = "Usage: run_msconvert.rb --input_files=<file1,file2>"

    opts.on("--input_files=MANDATORY", "--input_fies MANDATORY", "Input Files") do |v|
      options[:input_files] = v
    end
   
 end.parse!

#loop through each input file

options[:input_files].split(',').each do |f|

system "#{MSCONVERT_CMD} --mgf #{f}"

end



