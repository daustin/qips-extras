#!usr/bin/env ruby

#########################################
##
#    David Austin @ UPENN
#    runs xinteract
#    accepts pep xml input files
#    --input_files='file1,file2'
#

require 'rubygems'
require 'optparse'
require 'json'
require 'erubis'

#command to execute
CMD = '/opt/tpp/bin/xinteract'
TPP_PATH = '/opt/tpp/bin'

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
  
  out += "Updating Path"
  `export PATH=$PATH:#{TPP_PATH}`
  out += "Analysing files...\n"
  out += "Running: #{CMD} #{other_args.join(' ')} #{input_files.split(',').join(' ')}\n"
  out += `#{CMD} #{other_args.join(' ')} #{input_files.split(',').join(' ')} 2> temp.err` #redirects to output file, and redirects error
  out += "\n--------FROM STDERR---------\n"
  out += "#{$?}: " + `cat temp.err` + "\n" unless $?.to_i == 0 # $? is a special var for error code of process

  #since xinteract outputs stderr normally, we have to check for errors another way.  lets just check for interact.xml
  unless File.exist?('interact.xml') || File.exist?('interact.pep.xml')
    
    error += "ERROR: Cannot find xinteract outputs interact.xml or interact.pep.xml"
    
  end


  #collect output files
  Dir.glob('{*.xsl,interact.pep.xml, interact.xml, interact.prot.xml, interact-prot.xml}').each do |f|
    outputs << f
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


