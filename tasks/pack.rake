task :environment

namespace :pack do

  desc "pack and move tarfile to root"
  task :tar => :environment do
    
    Dir.chdir 'bin' do
      `tar -czvf qips_extras.tgz *.*`
    
    end
    
    `mv -v ./bin/qips_extras.tgz .`
    
  end



end 

