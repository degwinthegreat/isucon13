# Requirements
# * ruby
# * curl
# * gh
#   * https://github.com/cli/cli
#   * gh auth login
#
# Usage
# * rake

# デプロイ先のサーバ
HOSTS = {
  host01: "isu1", # xxx.xxx.xxx.xxx", # front, db, app(uploader, auth), redis, memcached
  host02: "isu2", # xxx.xxx.xxx.xxx",  # app(main)
  host03: "isu3", # xxx.xxx.xxx.xxx", # app(main)
}

# BENCH_IP = "isu12fb"
# INITIALIZE_ENDPOINT = "https://isucondition.t.isucon.dev/initialize_from_local"

# デプロイ先のカレントディレクトリ
CURRENT_DIR = "/home/isucon/webapp"

# rubyアプリのディレクトリ
RUBY_APP_DIR = "/home/isucon/webapp/ruby"

# アプリのservice名
APP_SERVICE_NAME = "isupipe-ruby.service"

# デプロイを記録するissue
GITHUB_REPO     = "degwinthegreat/isucon13" # sue445/isucon11-qualify"
GITHUB_ISSUE_ID = 1

BUNDLE = "/home/isucon/local/ruby/bin/bundle"

CURL_COMMAND = <<~CURL
curl 'https://api.isunarabe.org/portal.Portal/GetBenchmarkJob' \
  -H 'authority: api.isunarabe.org' \
  -H 'accept: application/grpc-web-text' \
  -H 'accept-language: ja-JP,ja;q=0.9,en-US;q=0.8,en;q=0.7' \
  -H 'content-type: application/grpc-web-text' \
  -H 'cookie: SESSION=4PVa58FdltVKEgZrs6jw62WeduSZfjSO4n7UVQsALj%2Fd07OdTCymm58h6wK2niuht8wLNySqNy2kj12VNWF8SpfT38uDrxbN%2FFD0i5PfYRRJ7zm1kkB4bq7tCqp4tAgT6%2FFi' \
  -H 'origin: https://isunarabe.org' \
  -H 'referer: https://isunarabe.org/' \
  -H 'sec-ch-ua: "Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: same-site' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
  -H 'x-grpc-web: 1' \
  --data-raw 'AAAAAAMI3UE=' \
  --compressed
CURL

ALP_MATCHING_GROUP = [
  "/api/livestream/[0-9]+$",
  "/api/livestream/[0-9]+/statistics$",
  "/api/livestream/[0-9]+/enter$",
  "/api/livestream/[0-9]+/livecomment$",
  "/api/livestream/[0-9]+/livecomment/[0-9]+$",
  "/api/livestream/[0-9]+/livecomment/[0-9]+/report$",
  "/api/livestream/[0-9]+/reaction$",
  "/api/livestream/[0-9]+/statistics$",
  "/api/livestream/[0-9]+/report$",
  "/api/livestream/[0-9]+/exit$",
  "/api/livestream/[0-9]+/moderate$",
  "/api/livestream/[0-9]+/ngwords$",
  "/api/user/[0-9a-zA-Z]+/icon$",
  "/api/user/[0-9a-zA-Z]+/statistics$",
  "/api/user/[0-9a-zA-Z]+/theme$",
  "/api/user/[0-9a-zA-Z]+/livestream$",
].join(',')

def exec(ip_address, command, cwd: CURRENT_DIR)
  sh %Q(ssh isucon@#{ip_address} 'cd #{cwd} && #{command}')
end

namespace :deploy do
  HOSTS.each do |name, ip_address|
    desc "Deploy to #{name}"
    task name do
      puts "[deploy:#{name}] START"

      # common
      exec ip_address, "git pull origin main --ff"

      # exec ip_address, "sudo cp infra/systemd/#{APP_SERVICE_NAME} /etc/systemd/system/#{APP_SERVICE_NAME}"

      # systemdの更新後にdaemon-reloadする
      exec ip_address, "sudo systemctl daemon-reload"

      # TODO: 終了10分前にdisableすること！！！！！！
      # exec ip_address, "sudo systemctl restart newrelic-infra"
      # exec ip_address, "sudo systemctl disable newrelic-infra"
      # exec ip_address, "sudo systemctl stop newrelic-infra"
      # exec ip_address, "sudo systemctl enable newrelic-infra"
      # exec ip_address, "sudo systemctl start newrelic-infra"

      # mysql
      case name
      when :host03
        exec ip_address, "sudo cp infra/mysql/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf"
        exec ip_address, "sudo mysqld --verbose --help > /dev/null"
        exec ip_address, "sudo systemctl restart mysql"
      else
        exec ip_address, "sudo systemctl disable --now mysql"
        exec ip_address, "sudo systemctl stop mysql"
      end

      # nginx
      case name
      when :host01
        exec ip_address, "sudo cp infra/nginx/isupipe.conf  /etc/nginx/sites-enabled/isupipe.conf"
        exec ip_address, "sudo nginx -t"
        exec ip_address, "sudo systemctl restart nginx"
      else
        exec ip_address, "sudo systemctl stop nginx"
      end

      # app
      case name
      when :host01, :host02
        exec ip_address, "#{BUNDLE} install --path vendor/bundle --jobs $(nproc)", cwd: RUBY_APP_DIR
        exec ip_address, "#{BUNDLE} config set --local path 'vendor/bundle'", cwd: RUBY_APP_DIR
        exec ip_address, "#{BUNDLE} config set --local jobs $(nproc)", cwd: RUBY_APP_DIR
        exec ip_address, "#{BUNDLE} install", cwd: RUBY_APP_DIR

        exec ip_address, "sudo systemctl disable --now isupipe-go.service" # isuconquest.go.service" # isucondition.go.service"
        exec ip_address, "sudo systemctl stop isupipe-go.service" # isuconquest.go.service" # isucondition.go.service"

        exec ip_address, "sudo systemctl stop #{APP_SERVICE_NAME}"
        exec ip_address, "sudo systemctl start #{APP_SERVICE_NAME}"
        exec ip_address, "sudo systemctl status #{APP_SERVICE_NAME}"
      else
        exec ip_address, "sudo systemctl disable --now #{APP_SERVICE_NAME}"
        exec ip_address, "sudo systemctl stop #{APP_SERVICE_NAME}"
      end


      # memcached
      # case name
      # when :host01
      #   exec ip_address, "sudo cp infra/memcached/memcached.conf /etc/memcached.conf"
      #   exec ip_address, "sudo systemctl restart memcached"
      # else
      #   exec ip_address, "sudo systemctl stop memcached"
      # end

      # redis
      # case name
      # when :host01
      #   exec ip_address, "sudo cp infra/redis/redis.conf /etc/redis/redis.conf"
      #   exec ip_address, "sudo systemctl restart redis-server"
      # else
      #   exec ip_address, "sudo systemctl stop redis-server"
      # end

      # sidekiq
      # case name
      # when :host01
      #   # exec ip_address, "#{BUNDLE} install --path vendor/bundle --jobs $(nproc)", cwd: "#{CURRENT_DIR}/webapp/ruby"
      #   # exec ip_address, "sudo systemctl stop isutrain-sidekiq.service"
      #   # exec ip_address, "sudo systemctl start isutrain-sidekiq.service"
      #   # exec ip_address, "sudo systemctl status isutrain-sidekiq.service"
      # else
      #   # exec ip_address, "sudo systemctl stop isutrain-sidekiq.service"
      # end

      # docker-compose
      # case name
      # when :host01
      #   # exec ip_address, "docker-compose -f webapp/docker-compose.yml -f webapp/docker-compose.ruby.yml down"
      #   # exec ip_address, "docker-compose -f webapp/docker-compose.yml up -d --build"
      # else
      #   # exec ip_address, "docker-compose -f webapp/docker-compose.yml -f webapp/docker-compose.ruby.yml down"
      # end

      puts "[deploy:#{name}] END"
    end
  end
end

desc "Prepare for deploy"
task :setup do
  sh "git push"
end

desc "Deploy to all hosts"
multitask :deploy => HOSTS.keys.map { |name| "deploy:#{name}" }

desc "POST /initialize"
task :initialize do
  # sh "curl --max-time 20 -X POST --retry 3 --fail #{INITIALIZE_ENDPOINT}"
end

desc "Record current commit to issue"
task :record do
  revision = `git rev-parse --short HEAD`.strip

  current_tag = [
    Time.now.strftime("%Y%m%d-%H%M%S"),
    `whoami`.strip
  ].join("-")

  message = ":rocket: Deployed #{revision} [#{current_tag}](https://github.com/#{GITHUB_REPO}/releases/tag/#{current_tag})"

  # 直前のリリースのtagを取得する
  before_tag = `git tag | tail -n 1`.strip

  unless before_tag.empty?
    message << " ([compare](https://github.com/#{GITHUB_REPO}/compare/#{before_tag}...#{current_tag}))"
  end

  sh "git tag -a #{current_tag} -m 'Release #{current_tag}'"
  sh "git push --tags"

  sh "gh issue comment --repo #{GITHUB_REPO} #{GITHUB_ISSUE_ID} --body '#{message}'"
end

task :all => [:setup, :deploy, :initialize, :record, :bench]

task :push => [:setup, :deploy, :initialize, :record] # :all

desc "alp_install"
task :alp_install do
  HOSTS.each do |name, ip_address|

    exec ip_address, "sudo apt-get install unzip"
    exec ip_address, "wget https://github.com/tkuchiki/alp/releases/download/v1.0.21/alp_linux_amd64.zip"
    exec ip_address, "unzip alp_linux_amd64.zip"
    exec ip_address, "sudo install alp /usr/local/bin/alp"
  end
end

desc "slp_install"
task :slp_install do
  HOSTS.each do |name, ip_address|
    exec ip_address, "wget https://github.com/tkuchiki/slp/releases/download/v0.2.0/slp_linux_amd64.zip"
    exec ip_address, "unzip slp_linux_amd64.zip"
    exec ip_address, "sudo install slp /usr/local/bin/slp"
  end
end

desc "bench"
task :bench do
    # mysql
    HOSTS.each do |name, ip_address|
        exec ip_address, "echo -n | sudo tee /var/log/mysql/slow.log"
        exec ip_address, "echo -n | sudo tee /home/isucon/access.log"
        exec ip_address, "sudo rm -f /tmp/sql.log"
        exec ip_address, "rm -rf tmp/*", cwd: RUBY_APP_DIR
    end

    # puts `#{CURL_COMMAND}`
end

desc "collect metrics"
task :measure do
  # exec BENCH_IP, "sudo systemctl stop jiaapi-mock.service"
  timestamp = Time.now.strftime('%Y%m%d%H%M')

#   exec BENCH_IP, "ISUXBENCH_TARGET=13.231.185.75 /home/isucon/bin/benchmarker --stage=prod --request-timeout=10s --initialize-request-timeout=60s > /tmp/bench/#{timestamp}.txt"
#   sh "scp #{BENCH_IP}:/tmp/bench/#{timestamp}.txt ./log/bench/#{timestamp}.txt"

  HOSTS.each do |name, ip_address|
    exec ip_address, "mkdir -p /tmp/alp/"
    exec ip_address, "mkdir -p /tmp/slp/"
  end

  exec HOSTS[:host01], "alp ltsv --file=/home/isucon/access.log -r --sort=sum -m '#{ALP_MATCHING_GROUP}' --format html > /tmp/alp/#{timestamp}.html"
  sh "scp #{HOSTS[:host01]}:/tmp/alp/#{timestamp}.html ./log/alp/#{timestamp}.html"

  exec HOSTS[:host03], "sudo cat /var/log/mysql/slow.log | slp my --format html > /tmp/slp/#{timestamp}.html"
  sh "scp #{HOSTS[:host03]}:/tmp/slp/#{timestamp}.html ./log/slp/#{timestamp}.html"

  # sh "scp -r #{HOSTS[:host01]}:/home/isucon/webapp/ruby/tmp ./log/stackprof"

  sh "git pull"
  sh "git add -A"
  sh "git commit -m 'bench #{timestamp}'"
  sh "git push origin main"
end
