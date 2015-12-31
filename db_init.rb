require 'sequel'
require 'yaml'
require 'logger'

unless defined? DB
    basedir = File.dirname(__FILE__)
    config = YAML.load_file("#{basedir}/config.yml")

    if `hostname` =~ /^ip-/ and ENV['HUBSERVER_DATABASE_TYPE'].nil?
        ENV['HUBSERVER_DATABASE_TYPE']='mysql'
    end

    mode = nil
    if ENV['HUBSERVER_DATABASE_TYPE'].nil? or 
      !(["mysql", "sqlite"].include? ENV['HUBSERVER_DATABASE_TYPE'])
        puts "environment variable HUBSERVER_DATABASE_TYPE must be set to"
        puts "mysql or sqlite."
        exit
    else
        mode = ENV['HUBSERVER_DATABASE_TYPE'].to_sym
    end

    url = nil
    if mode == :mysql
        url = config['mysql_url']
    else
        url = "sqlite://#{basedir}/#{config['sqlite_filename']}"
    end

    DB = Sequel.connect(url)
end

DB.loggers << Logger.new($stdout)
