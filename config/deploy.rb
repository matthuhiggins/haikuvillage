set :application, "haiku-x"
set :repository,  "svn://www.spiz.us/haiku/trunk/ruby/"
set :scm_username, "matt"
set :scm_password, "sa"
set :user, "matt"
set :deploy_to, "/var/www/#{application}"
server "haikuvillage.com", :app, :web, :db, :primary => true

namespace :passenger do
  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

after :deploy, "passenger:restart"