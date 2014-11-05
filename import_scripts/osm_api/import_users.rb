class UserImport

  require_relative 'osm_api'

  attr_reader :user_api, :success_log, :fail_log, :uids

  def initialize(limit=nil)
    @user_api = OSMAPI.new("http://api.openstreetmap.org/api/0.6/user/")

    #Open Log files
    # @success_log = LogFile.new("logs/users","successful")
    # @fail_log    = LogFile.new("logs/users","failed")

    @limit = limit
  end

  def distinct_uids
    @uids ||= get_distinct_uids
  end


  def get_distinct_uids
    uids = []
    uids = DatabaseConnection.database["nodes"].distinct("uid")
    uids += DatabaseConnection.database["ways"].distinct("uid")
    uids += DatabaseConnection.database["relations"].distinct("uid")
    if @limit.nil? 
      return uids.uniq!
    else 
      return uids.uniq!.first(@limit)
    end
  end

  def import_user_objects
    distinct_uids.each_with_index do |changeset_id, index|
      this_user = user_api.hit_api(changeset_id)

      user_obj = User.new convert_osm_api_to_domain_object_hash this_user
      user_obj.save!
    end

    if (index%10).zero?
      print '.'
    elsif (index%101).zero?
      print index
    end
  end

  def convert_osm_api_to_domain_object_hash(osm_api_hash)
    data = osm_api_hash[:osm][:user]
    data[:user] = data[:display_name]
    data[:uid]  = data[:id]
    data[:account_created] = Time.parse data[:account_created]

    data.delete :display_name
    data.delete :id

    return data
  end

end