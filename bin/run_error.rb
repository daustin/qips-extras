#!/opt/local/bin/ruby

#########################################
##
#    David Austin @ UPENN
#    Throws error!
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
  opts.banner = "Usage: run_error.rb [options]"
  
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

    out += "Throwing error..."
    #only throw error!
    error = "FORCED ERROR"

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









