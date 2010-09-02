#!/usr/bin/env ruby

#########################################
##
#    David Austin @ UPENN
#    wrapper for tandem
#    generates input.xml based on the folling args:
#    --input_files='file1,file2'
#    --taxonomy=human
#

require 'rubygems'
require 'optparse'
require 'json'

require 'erubis'

#command to execute
CMD = '/opt/tandem/bin/tandem'
INPUT_XML_FILE = 'input.xml'

#holder for stdout from exec
out = ''

#list of output files
outputs = Array.new

#lets get input files from command line
options = {}

OptionParser.new do |opts|
  
  opts.banner = "Usage: run_tandem.rb --input_files=<file1,file2> --taxon=<Taxonomy>"

  opts.on("--taxon=MANDATORY", "--taxon MANDATORY", "Taxon") do |v|
    options[:taxon] = v
  end
  
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



  out += "Using Taxon: #{options[:taxon]}\n"
  out += "Searching #{options[:input_files].split(',').size} input files...\n"
  
  # FIRST GENERATE input.xml file

  input_xml_template = ""
  input_xml_template += "<?xml version=\"1.0\"?>\n"

  input_xml_template += "<bioml>\n"

  input_xml_template += "<note type=\"input\" label=\"list path, default parameters\">default_input.xml</note>\n"
  input_xml_template += "<note type=\"input\" label=\"list path, taxonomy information\">taxonomy.xml</note>\n"
  input_xml_template += "<note type=\"input\" label=\"protein, taxon\">#{options[:taxon]}</note>\n"
  
  #loop through each input file

  options[:input_files].split(',').each do |f|

    if f =~ /\.mgf/
      input_xml_template += "<note type=\"input\" label=\"spectrum, path\">#{f}</note>\n"
    end
    
  end

  input_xml_template += "<note type=\"input\" label=\"output, path\">output.xml</note>\n"
  input_xml_template += "</bioml>\n"

  #now write to xml file

  File.open("#{INPUT_XML_FILE}", "w+"){|io| io.write(input_xml_template) }

  out += "Searching...\n"
  out += `#{CMD} #{INPUT_XML_FILE} 2> temp.err` #redirects to output file, and redirects error
  error += "#{$?}: " + `cat temp.err` + "\n" unless $?.to_i == 0 # $? is a special var for error code of process
  # error = "FORCED ERROR" if rand(2) == 1 # uncomment to force an error half the time

  xml_outs = `ls -1 output*.xml`
  xml_outs.each do |l|
    outputs << l.strip
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


