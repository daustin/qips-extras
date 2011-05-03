#!/usr/bin/env ruby

#########################################
##
#    David Austin @ UPENN
#    runs mascot search for given input file(s)
#    accepts mgf files
#    --input_files='file1,file2'
#    --taxonomy=human
#

require 'rubygems'
require 'optparse'
require 'json'
require 'restclient'

MASCOT_ROOT =  "/mnt/mascot"
SEARCH_CMD = './nph-mascot.exe 1 < %s'

#holder for stdout from exec
out = ''

#list of output files
outputs = Array.new

#lets get input files from command line
options = {}

OptionParser.new do |opts|

  opts.banner = "Usage: run_localmascot.rb --input_files=<file1,file2>> [--params_file=mascot.par]"

  opts.on("--params_file=MANDATORY", "--params_file MANDATORY", "Params File") do |v|
    options[:params_file] = v
  end

   opts.on("--input_files=MANDATORY", "--input_fies MANDATORY", "Input Files") do |v|
     options[:input_files] = v
   end

end.parse!

# loop through each input file and run command
# redirects error to error file and then captures error

error = ''

begin

  ##################################################################################################
  #
  #   we do all the work in a begin / rescue block just in case there are any unforseen exceptions.
  #   this way anything that goes wrong is caught and passed back to qips-node daemon
  #

  ## First set params
  params_file = ''

  if options[:params_file]

    #check file
    if File.exist?(options[:params_file])
      params_file = options[:params_file]
    else
      throw "PARAMS FILE NOT FOUND: #{options[:params_file]}\n"
    end

  else

    # try to find a params file if not specified
    a = Dir.glob("*.par")
    if a.empty?
      out += "Could not find mascot params file. Will use default params.\n "
    else
      params_file = a[0]
    end

  end

  out += "Using Params file: #{params_file}\n" unless params_file == ''
  out += "Searching #{options[:input_files].split(',').size} input files...\n"

  #loop through each input file

  options[:input_files].split(',').each do |f|
    out += "Processing #{f}..."
    infile = f

    # out html from mascot server
    mascotout = File.open("MASCOT_#{File.basename(infile,'.mgf')}.html", "w+")

    out += "Sending #{infile} to mascot server\n"

    # mascotparams['FILE'] = File.new(infile)

    # submit file
    submit_file_name = "/tmp/mascot_input_#{File.basename(infile,".asc")}.asc"
    # post
    system( "echo \"-----------------------------16838575810113\nContent-Disposition: form-data; name=\"QUE\"\n\n\" > #{submit_file_name}")
    # concat the mascot params and input file
    system("cat #{File.expand_path(params_file)} #{File.expand_path(infile)}  > #{submit_file_name}")
    # end submit_file
    system("echo \"-----------------------------16838575810113--\" >  #{submit_file_name}")
    run_dir = Dir.pwd
    Dir.chdir(MASCOT_ROOT + "/cgi")
    body  =  `./nph-mascot.exe 1 < \"#{submit_file_name}\"`
    Dir.chdir(run_dir)
    mascotout.write(body)
    mascotout.close
    outputs << "MASCOT_#{File.basename(infile,'.mgf')}.html"

    # now fetch dat file and rename to match infile

    if body  =~ /<A HREF.*?file=\.\.\/(data\/.+?\.dat)/ then

      # get date dir and basename
      dat_path = "#{MASCOT_ROOT}/#{$1}"

      out += "Fetching #{dat_path} from mascot server directory and renaming\n"
      outputfile = "#{File.basename(infile,'.mgf')}.dat"
      system("cp #{dat_path} #{outputfile}")
      outputs << outputfile
    else

      # can't get datfile so throw an error
      error += "ERROR:  Could not find a dat file in mascot search results for #{infile}\n\n"
      error += "MASCOT OUT SOURCE: #{body}\n\n"

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

