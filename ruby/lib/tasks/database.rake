namespace :db do
  task :redo => ['db:migrate:reset', 'db:fixtures:load']
end