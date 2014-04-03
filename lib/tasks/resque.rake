# Start a worker with proper env vars and output redirection
def run_worker(queue, count = 1)
  puts "Starting #{count} worker(s) with QUEUE: #{queue}"
  ops = {:pgroup => true, :err => [(Rails.root + "log/workers_error.log").to_s, "a"],
                          :out => [(Rails.root + "log/workers.log").to_s, "a"]}
  env_vars = {
    "VERBOSE" => '1',
    "QUEUE" => queue.to_s,
    "RAILS_ENV" => Rails.env
  }
  count.times {
    ## Using Kernel.spawn and Process.detach because regular system() call would
    ## cause the processes to quit when capistrano finishes
    pid = spawn(env_vars, "bundle exec rake resque:work", ops)
    Process.detach(pid)
  }
end

namespace :resque do
  task :setup => :environment

  desc "Restart running workers"
  task :restart_workers => :environment do
    Rake::Task['resque:stop_workers'].invoke
    Rake::Task['resque:start_workers'].invoke
  end

  desc "Quit running workers"
  task :stop_workers => :environment do
    pids = Array.new

    Resque.workers.each do |worker|
      pids.concat(worker.worker_pids)
    end

    if pids.empty?
      puts "No workers to kill"
    else
      syscmd = "kill -s QUIT #{pids.uniq.join(' ')}"
      puts "Running syscmd: #{syscmd}"
      system(syscmd)
    end
  end

  desc "Start workers"
  task :start_workers => :environment do
    run_worker("*", 2)
  end
end

# http://stackoverflow.com/questions/6137570/resque-enqueue-failing-on-second-run
require 'resque/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'

  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
