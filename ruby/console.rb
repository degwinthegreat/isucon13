# how to use: $ bundle exec ruby console.rb
require_relative 'app'
require 'irb'

db = Mysql2::Client.new(
  host: ENV.fetch('ISUCON13_MYSQL_DIALCONFIG_ADDRESS', '127.0.0.1'),
  port: ENV.fetch('ISUCON13_MYSQL_DIALCONFIG_PORT', '3306').to_i,
  username: ENV.fetch('ISUCON13_MYSQL_DIALCONFIG_USER', 'isucon'),
  password: ENV.fetch('ISUCON13_MYSQL_DIALCONFIG_PASSWORD', 'isucon'),
  database: ENV.fetch('ISUCON13_MYSQL_DIALCONFIG_DATABASE', 'isupipe'),
  symbolize_keys: true,
  cast_booleans: true,
  reconnect: true,
)

def db_transaction(db, &block)
  db.query('BEGIN')
  ok = false
  begin
    retval = block.call(db)
    db.query('COMMIT')
    ok = true
    retval
  ensure
    unless ok
      db.query('ROLLBACK')
    end
  end
end

# how to use
# db_transaction(db) do |tx|
#   tx.xquery('SELECT * FROM themes WHERE user_id = ?', 1).first
# end

binding.irb
