require 'spec_helper'
require 'import_scripts/pbf_to_mongo'

describe OSMPBF do

	#Open the PBF file
	before :all do
		#Initialize a database connection
		DatabaseConnection.new(database: 'osm-test')
		@conn = OSMPBF.new(end_date: )
		@conn.open_parser("spec/import/test_files/managua.osm.pbf")
		@conn.file_stats
	end

	it "Can create node objects from the PBF" do
		@conn.parse_to_collection(object_type="nodes", lim=nil)
	end

	it "Can create way objects from the PBF" do
		@conn.parse_to_collection(object_type="ways", lim=nil)
	end

	it "Can create Relation objects from the PBF" do
		@conn.parse_to_collection(object_type="relations", lim=nil)
	end
end
