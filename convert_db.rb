## Run me via cron.
## 'HUBSERVER_DATABASE_TYPE' must be set in crontab

#ENV['HUBSERVER_DATABASE_TYPE'] = 'mysql'

require './db_init.rb'
require 'fileutils'
require 'sequel'
require 'yaml'

@basedir = File.dirname(__FILE__)

timestamp =  DB[:timestamp].first[:timestamp]

cachefile = "#{@basedir}/dbtimestamp.cache"

@config = YAML.load_file("#{@basedir}/config.yml")

db_name = @config['mysql_url'].split("/").last
url2 = @config['mysql_url'].sub(db_name, "information_schema")
DB2 = Sequel.connect(url2)

table_created_at = DB2[:tables].where(:table_schema => db_name).max(:create_time)

def convert_db()
    mysql2_url = @config['mysql_url'].sub(/^mysql:/, "mysql2:")
    outfile = "#{@basedir}/#{@config['sqlite_filename']}"
    outfile_tmp = outfile + "_tmp"
    FileUtils.rm_rf outfile_tmp
    res = `sequel #{mysql2_url} -C sqlite://#{outfile_tmp}`
    FileUtils.rm_rf outfile
    FileUtils.mv outfile_tmp, outfile
    #puts "does it exist? #{File.exists? outfile}"
end

if (File.exists?(cachefile))
    cached_time = Time.parse(File.readlines(cachefile).first)
    if (timestamp > cached_time or table_created_at > cached_time)
        convert_db()
    end
else
    convert_db()
end

f = File.open(cachefile, "w")
f.write(timestamp.to_s)
f.close
