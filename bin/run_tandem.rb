#!/opt/local/bin/ruby

#########################################
##
#    wrapper for tandem
#    generates input.xml based on the folling args:
#    --input_files='file1,file2'
#    --taxonomy=human
#    
#

require 'rubygems'
require 'erubis'
require 'optparse'
 
#tandem command 
TANDEM_CMD = '/opt/tandem/bin/tandem'
INPUT_XML_FILE = 'input.xml'

#lets get input files and taxon from command line
options = {}

require 'optparse'

 options = {}
 OptionParser.new do |opts|
   opts.banner = "Usage: run_tandem.rb --input_files=<file1,file2>"

   opts.on("--taxon=MANDATORY", "--taxon MANDATORY", "Taxon") do |v|
     options[:taxon] = v
   end
   
    opts.on("--input_files=MANDATORY", "--input_fies MANDATORY", "Input Files") do |v|
      options[:input_files] = v
    end
   
 end.parse!

puts options[:taxon]
puts options[:input_files]

input_xml_template = ""
input_xml_template += "<?xml version=\"1.0\"?>\n"

input_xml_template += "<bioml>\n"

input_xml_template += "<note type=\"input\" label=\"list path, default parameters\">default_input.xml</note>\n"
input_xml_template += "<note type=\"input\" label=\"list path, taxonomy information\">taxonomy.xml</note>\n"
input_xml_template += "<note type=\"input\" label=\"protein, taxon\">#{options[:taxon]}</note>\n"

#loop through each input file

options[:input_files].split(',').each do |f|

input_xml_template += "<note type=\"input\" label=\"spectrum, path\">#{f}</note>\n" if f =~ /\.mgf/


end

input_xml_template += "<note type=\"input\" label=\"output, path\">output.xml</note>\n"
input_xml_template += "</bioml>\n"

#now write to xml file

File.open("#{INPUT_XML_FILE}", "w+"){|io| io.write(input_xml_template) }


system "#{TANDEM_CMD} #{INPUT_XML_FILE}"



