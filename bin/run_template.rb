#!usr/bin/env ruby

#########################################
##
#    David Austin @ UPENN
#    Simple example loops through input files and reverses them
#    then adds .rev to the end and passes relevent info back to node daemon
#    --input_files='file1,file2'
#   
#    This can be modified to fit most needs. 
#

require 'rubygems'
require 'optparse'
require 'json' 

#command to execute
CMD = 'rev'

#holder for stdout from exec
out = ''

#list of output files
outputs = Array.new

#lets get input files from command line
options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: run_template.rb [options]"
  
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
    
    out += "Processing #{f}...\n"
    out += `#{CMD} #{f} 1> #{f}.rev 2> temp.err` #redirects to output file, and redirects error
    outputs << "#{f}.rev"
    error += "#{$?}: " + `cat temp.err` + "\n" unless $?.to_i == 0 # $? is a special var for error code of process
    # error = "FORCED ERROR" if rand(2) == 1 # uncomment to force an error half the time

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









