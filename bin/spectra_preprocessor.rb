#!/opt/local/bin/ruby

#########################################
##
#    David Austin @ UPENN
#    Loops through mzML spectra files, performs an optimization based on search algorithm, convets it to mgf output 
#    --optimize=<sequest|mascot>  --input_files='file1,file2'
#   
#    

require 'rubygems'
require 'optparse'
require 'json' 

################  HELPER CLASSES##############################

class IonOptimizer

  def self.optimize(ion_array = [], algo = 'mascot')

    case algo    
    when 'mascot'
      
      ion_array.sort!{ |x,y| y.intensity.to_f <=> x.intensity.to_f} #sort ions descreasing intensity and take top 200
      return ion_array[0..199]        
      
    when 'sequest'
     
     #sort first
     
     topx = 6
     window = 30
     
     optimized_array = Array.new
     
     while ! ion_array.empty?
       
       work_array = Array.new
       
       ion_array.sort!{ |x,y| y.intensity.to_f <=> x.intensity.to_f}
       
       #pick top hit
       
       top_ion = ion_array[0]
       
       #now look through and grab any mz's that are in range
       
       ion_array.each do |i|
         
         work_array << ion_array.delete(i) if (i.mz.to_f > (top_ion.mz.to_f - window)) || (i.mz.to_f < (top_ion.mz.to_f + window))
          
       end
       
       # now just sort and add topx to optimized_array
       
       work_array.sort!{ |x,y| y.intensity.to_f <=> x.intensity.to_f}
       
       optimized_array.concat(work_array[0..(topx-1)])
       
     end
     
     return optimized_array.sort!{ |x,y| x.mz.to_f <=> y.mz.to_f}
        
    else
      raise 'Invalid optimize algorithm.  choose sequest or mascot.'
    end  
  end
  
end
  

class MGFPrinter

  def self.print(ions, s)
  
    #now we print!
    mgfout = ''
    mgfout +=  "BEGIN IONS\n"
    mgfout +=  "TITLE=#{s.id}\n"
    mgfout +=  "RTINSECONDS=#{s.retention_time}\n"
    mgfout +=  "PEPMASS=#{s.precursor_mass} #{s.precursor_intensity}\n"

    0.upto(ions.length-1) do |i|
      mgfout +=  "#{sprintf('%0.7f', ions[i].mz)} #{sprintf('%0.5f', ions[i].intensity)}\n"
    end

    mgfout +=  "END IONS\n"

    return mgfout
  
  end
  
end


#####################################################################


#holder for stdout from exec
out = ''

#list of output files
outputs = Array.new

#lets get input files from command line
options = {:optimize => 'mascot'} #defaults

OptionParser.new do |opts|
  opts.banner = "Usage: spectra_preprocessor.rb --optimize=<sequest|mascot> --input_files=<file1.mzML,file2.mzML>"
  
  opts.on("--input_files=MANDATORY", "--input_files MANDATORY", "Input Files") do |v|
    options[:input_files] = v
  end
  
  opts.on("--optimize=MANDATORY", "--optimize MANDATORY", "Algorithm Optimization") do |v|
    options[:optimize] = v
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

  require 'mzml'

  Ion = Struct.new(:mz, :intensity)

  options[:input_files].split(',').each do |f|

    raise "Invalid input extention." unless f =~ /\.mzML/

    #each basename
    out += "Optimizing #{f}...\n"

    #first load the doc
    mzml =  MzML::Doc.new(f)

    # open out file
    fout = File.open("#{File.basename(f, ".mzML")}.mgf", "w+") 

    #add to output array
    outputs << "#{File.basename(f, ".mzML")}.mgf"

    #now lets loop through each spectrum.
    sorted_keys = mzml.parse_index_list[:spectrum].keys.sort{ |x,y| x.split('=')[3].to_i <=> y.split('=')[3].to_i } # sort spectra just as preference

    sorted_keys.each do |t|
    
      s = mzml.spectrum(t)

      unless  s.precursor_list.nil? || s.precursor_list.empty? # make sure it is MS/MS

        #now we do the work
        
        ion_array = Array.new
        
        #load up the ions
    
        0.upto(s.mz.length-1) do |i|
        
          ion_array << Ion.new(s.mz[i], s.intensity[i])
        
        end
      
        #optimize the ions
        optimized_ions = IonOptimizer.optimize(ion_array, options[:optimize])
        
        out += "Printing optimized mgf file for #{t}...\n"
        
        #just print the mgf
        fout.write(MGFPrinter.print(optimized_ions, s))
        
      
      end
    
    
    end
    
    
    fout.close
  

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




