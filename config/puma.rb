threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

#port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
daemonize true
pidfile 'tmp/pids/puma.pid'

if "development" == ENV.fetch("RAILS_ENV") { "development" }
  if "start"==ARGV[0] then
    if File.exist?("tmp/pids/puma.pid") then
      puts "Already booted puma sever!"
      exit 
    end

    for i in 0..100 do
      begin
        s = TCPServer.open(3000+i)
      rescue
      end
      unless s.nil? then
        port = s.addr[1]
        s.close
        break
      end
    end

    ssl_bind '0.0.0.0', port, {
      key: '/etc/letsencrypt/live/docoiku.com/privkey.pem',
      cert: '/etc/letsencrypt/live/docoiku.com/fullchain.pem',
      verify_mode: "none"
    }

    puts "listening 0.0.0.0:#{port}"
  end
end

plugin :tmp_restart
