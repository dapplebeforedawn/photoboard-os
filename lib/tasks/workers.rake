require 'heroku-api'

desc "Manage workers for queues"
# IMPORTANT: .env has the production app set in development.  Running this task
# in development will effect the prouction app.

namespace :queue_workers do
  task :stop => :environment do
    queue_size = Sidekiq::Stats.new.queues.values.sum
    active_workers = Sidekiq::Workers.new.size

    # Scale down workers if nothing is going on
    puts "Queue Size: #{queue_size} -- Active Workers: #{active_workers}"
    if queue_size.zero? && active_workers.zero?
      heroku = Heroku::WorkerMgr.new
      heroku.scale_workers 0
    end
  end

  task :start => :environment do
    queue_size = Sidekiq::Stats.new.queues.values.sum

    # Queue up the photos it looks like they get into the queue async'ly
    # So if we add any, lets track them here and demand that the worker start
    queue_future_size = RawPhoto.size
    RawPhoto.files.each do |file|
      PhotoProcessor.perform_async file.key
    end

    # Scale up workers if there's work to be done, and there' aren't already
    # dynos running
    heroku = Heroku::WorkerMgr.new
    puts "Future Size: #{queue_future_size} -- Queue Size: #{queue_size} -- Has Workers: #{heroku.has_queue_worker?}"
    if (!queue_future_size.zero? || !queue_size.zero?) && !heroku.has_queue_worker?
      heroku.scale_workers 1
    end
  end
end

class Heroku::WorkerMgr
  AppName     = ENV['APP_NAME']
  APIKey      = ENV['HEROKU_API_KEY']
  Command     = "bundle exec sidekiq -c 1"
  ProcessName = "worker"
  ProcCommand = "start worker"

  def initialize
    @heroku = Heroku::API.new(:api_key => APIKey)
  end

  def scale_workers size
    puts "Scaling to #{size}:\n"
    puts @heroku.post_ps_scale(AppName, ProcessName, size).inspect
  end

  # Sample response to `get_ps.body`:
  #   [
  #     {"app_name"=>"lorenz-photoboard", "pretty_state"=>"idle for 14h", "process"=>"web.1", "state"=>"idle", "type"=>"Ps", "id"=>"9525ae1a-4cfd-4de3-ac32-236bb23782af", "command"=>"unicorn_rails -l $PORT -E $RACK_ENV", "rendezvous_url"=>nil, "elapsed"=>50725, "attached"=>nil, "transitioned_at"=>"2013/06/15 18:32:08 -0700", "release"=>18, "upid"=>nil, "action"=>"down", "size"=>1}, 
  #     {"app_name"=>"lorenz-photoboard", "pretty_state"=>"up for 3m", "process"=>"worker.1", "state"=>"up", "type"=>"Ps", "id"=>"1971610b-1434-473b-abd7-869c7594f9f5", "command"=>"bundle exec sidekiq", "rendezvous_url"=>nil, "elapsed"=>196, "attached"=>nil, "transitioned_at"=>"2013/06/16 08:34:17 -0700", "release"=>18, "upid"=>nil, "action"=>"up", "size"=>1}
  #   ]
  #
  def has_queue_worker?
    @heroku.get_ps(AppName).body.any? { |descr| descr['process'].match(/^#{ProcessName}/) && descr['command'] == Command }
  end

end

