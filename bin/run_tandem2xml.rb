#!/opt/local/bin/ruby

#########################################
##
#    wrapper for Tandem2XML
#    converts tandem xml output to pep xml:
#    --input_files='file1,file2'
#   
#    
#

require 'rubygems'
require 'optparse'
 
#command 
CMD= '/opt/tpp/bin/Tandem2XML'
VALID_MATCH='\.xml'

#lets get input files and taxon from command line
options = {}

require 'optparse'

 options = {}
 OptionParser.new do |opts|
   opts.banner = "Usage: example.rb [options]"

    opts.on("--input_files=MANDATORY", "--input_fies MANDATORY", "Input Files") do |v|
      options[:input_files] = v
    end
   
 end.parse!

#loop through each input file

options[:input_files].split(',').each do |f|

system "#{CMD} #{f} #{f.chomp('.xml')}.pep.xml" if f =~ /#{VALID_MATCH}/

end



