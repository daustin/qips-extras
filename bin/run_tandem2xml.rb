#!/usr/bin/env ruby

#########################################
##
#    David Austin @ UPENN
#    wrapper for Tandem2XML
#    converts tandem xml output to pep xml:
#    --input_files='file1,file2'
#

require 'rubygems'
require 'optparse'
require 'json' 

#command to execute
CMD = '/opt/tpp/bin/Tandem2XML'
VALID_MATCH='\.xml'

#holder for stdout from exec
out = ''

#list of output files
outputs = Array.new

#lets get input files from command line
options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: run_tandem2xml.rb [options]"
  
  opts.on("--input_files=MANDATORY", "--input_fies MANDATORY", "Input Files") do |v|
    options[:input_files] = v
  end
  
end.parse!

#loop through each input file and run command
# redirects error to error file and then captures error

error = ''

begin
  
  ##################################################################################################
  #
  #   we do all the work in a begin / rescue block just in case there are any unforseen exceptions.  
  #   this way anything that goes wrong is caught and passed back to qips-node daemon
  #

  options[:input_files].split(',').each do |f|
    #each basename
    if f =~ /#{VALID_MATCH}/
      out += "Converting #{f}...\n"
      out += `#{CMD} #{f} #{f.chomp('.xml')}.pep.xml 2> temp.err` #redirects to output file, and redirects error
      out.each_line do |l|
        outputs << "#{f.chomp('.xml')}.pep.xml"
      end
      error += "#{$?}: " + `cat temp.err` + "\n" unless $?.to_i == 0 # $? is a special var for error code of process
      # error = "FORCED ERROR" if rand(2) == 1 # uncomment to force an error half the time
    end
  end

rescue Exception => e

  error += "#{e.message}\n"
  error += e.backtrace.join("\n")
  error += "\n"
  
end


#now we pack everything in a hash and print it 

h = Hash.new
h["result"] = out
h["output_files"] = outputs
h["error"] = error unless error.empty?

puts h.to_json

