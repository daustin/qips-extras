#!/usr/bin/env ruby

#########################################
##
#    David Austin @ UPENN
#    wrapper for Mascot2XML
#    converts mascot dat output to pep xml:
#    --input_files='file1,file2'
#

require 'rubygems'
require 'optparse'
require 'json' 

#command to execute
CMD = '/opt/tpp/bin/Mascot2XML'
VALID_MATCH='\.dat'

#holder for stdout from exec
out = ''

#list of output files
outputs = Array.new

#lets get input files from command line
input_files = ''
other_args = []
ARGV.each do |arg|
  
  if arg =~ /input_files/
    input_files = arg.split('=')[1]
  else
    other_args << arg
  end
  
end

#loop through each input file and run command
# redirects error to error file and then captures error

error = ''

begin
  
  ##################################################################################################
  #
  #   we do all the work in a begin / rescue block just in case there are any unforseen exceptions.  
  #   this way anything that goes wrong is caught and passed back to qips-node daemon
  #

  input_files.split(',').each do |f|
    #each basename
    if f =~ /#{VALID_MATCH}/
      out += "Converting #{f}...\n"
      out += "Running #{CMD} #{f} #{other_args.join(' ')}"
      out += `#{CMD} #{f} #{other_args.join(' ')} 2> temp.err` #redirects to output file, and redirects error
      outputs << "#{f.chomp('.dat')}.pep.xml"
      outputs << "#{f.chomp('.dat')}.tgz"
      error += "#{$?}: " + `cat temp.err` + "\n" unless $?.to_i == 0 # $? is a special var for error code of process
    
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

