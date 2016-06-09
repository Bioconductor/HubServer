basedir = File.dirname(__FILE__)

require_relative "../models.rb"

Sequel.migration do
  up do
    DB.set_column_type :resources, :dataprovider, String, :text => true    
  end

  down do
    DB.set_column_type :resources, :dataprovider, String, :size => 255
  end
end
