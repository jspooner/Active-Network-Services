module Active
  module Services

    class GSAError < StandardError;  end

    class GSA < IActivity
      require 'nokogiri'
      require 'open-uri'
      attr_accessor :asset_type_id

      # EXAMPLE Data hash
      # {"title"=>"Birds of a Feather Run | Ashland, Oregon 97520 | Thursday ...", "language"=>"en", "url"=>"http://www.active.com/running/ashland-or/birds-of-a-feather-run-2010", "escapedUrl"=>"http://www.active.com/running/ashland-or/birds-of-a-feather-run-2010", "meta"=>{"city"=>"Ashland", "assetId"=>["4365AF63-B2AE-4A98-A403-5E30EB6D2D69", "4365af63-b2ae-4a98-a403-5e30eb6d2d69"], "substitutionUrl"=>"1845585", "trackbackurl"=>"http://www.active.com/running/ashland-or/birds-of-a-feather-run-2010", "contactName"=>"Hal Koerner", "eventDate"=>"2010-09-23T00:00:00-07:00", "eventLongitude"=>"-122.5526", "eventId"=>"1845585", "zip"=>"97520", "category"=>"Activities", "latitude"=>"42.12607", "google-site-verification"=>"", "participationCriteria"=>"All", "dma"=>"Medford - Klamath Falls", "country"=>"United States", "sortDate"=>"2000-09-23", "tag"=>["event:10", "Running:10"], "lastModifiedDateTime"=>"2010-09-23 03:04:55.463", "lastModifiedDate"=>"2010-09-23", "startDate"=>"2010-09-23", "contactPhone"=>"541-201-0014", "eventState"=>"Oregon", "splitMediaType"=>"Event", "onlineDonationAvailable"=>"0", "market"=>"Medford - Klamath Falls", "assetName"=>["Birds of a Feather Run", "Birds of a Feather Run"], "seourl"=>"http://www.active.com/running/ashland-or/birds-of-a-feather-run-2010", "assetTypeId"=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", "channel"=>"Running", "endTime"=>"0:00:00", "mediaType"=>"Event", "startTime"=>"0:00:00", "description"=>"", "longitude"=>"-122.5526", "UpdateDateTime"=>"9/22/2010 11:46:24 AM", "endDate"=>"2010-09-23", "onlineMembershipAvailable"=>"0", "onlineRegistrationAvailable"=>"false", "eventZip"=>"97520", "state"=>"Oregon", "estParticipants"=>"2000", "eventURL"=>"http://sorunners.org/", "eventLatitude"=>"42.12607", "keywords"=>"Event"}, "summary"=>"... Similar Running Events. I Ran for Sudan - Maple Valley First Annual 10K/2Mile      Kid's Run/Walk Maple Valley, Washington Sat, Oct 02, 2010; ... "}

      def initialize(json={})
        # need to hold on to original data
        @data = HashWithIndifferentAccess.new(json) || HashWithIndifferentAccess.new
        # self.title = @data['meta']['assetName'] || nil
        self.title = @data['title'] || nil
      end

      def source
        :gsa
      end

      def title=(value)
        @title = value
        if @title 
          @title = @title.split("|")[0].strip if @title.include?("|")          
          @title = @title.gsub(/<\/?[^>]*>/, "")
          @title = @title.gsub("...", "")
        end
      end

      def url
        @data["url"]
      end

      def categories
        if @data["meta"]["channel"].class==String
          [@data["meta"]["channel"]]
        else
          @data["meta"]["channel"]
        end
      end

      def asset_id
        return nil unless @data["meta"] and @data["meta"]["assetId"]
        value = @data["meta"]["assetId"]
        @asset_id = (value.class==Array) ? value[0] : value
      end
      
      def asset_type_id
        return nil unless @data["meta"] and @data["meta"]["assetTypeId"]        
        @data["meta"]["assetTypeId"]
      end
      
      def primary_category
        categories.first
      end

      def address
        @address = HashWithIndifferentAccess.new({
          :name    => @data["meta"]["location"],
          :city    => @data["meta"]["city"],
          :lat     => @data["meta"]["latitude"],
          :lng     => @data["meta"]["longitude"],
          :country => @data["meta"]["country"]
        })       
       @address[:address] = @data["meta"]["eventAddress"] || @data["meta"]["location"] || nil
       @address[:state] = @data["meta"]["eventState"] || @data["meta"]["state"]
       @address[:zip]   = @data["meta"]["eventZip"] || @data["meta"]["zip"]
       @address
      end

      def start_date
        if @data.has_key?("meta") and  @data["meta"].has_key?("eventDate")
          DateTime.parse( @data["meta"]["eventDate"] )
        elsif @data.has_key?("meta") and  @data["meta"].has_key?("startDate")
          DateTime.parse( @data["meta"]["startDate"] )
        else
          nil
        end
      end

      def start_time
        start_date
      end

      def end_date
        if @data.has_key?("meta") and  @data["meta"].has_key?("endDate")
          DateTime.parse @data["meta"]["endDate"]
        else
          nil
        end
      end

      def end_time
        end_date
      end

      def category
        primary_category
      end

      def contact_name
        if @data["meta"].has_key?("contactName") && !@data["meta"]["contactName"].blank?
          @data["meta"]["contactName"]
        end
      end
      
      def last_modified
        @data["meta"]["lastModifiedDateTime"] if @data["meta"].has_key?("lastModifiedDateTime") 
      end

      def contact_email
        if @data["meta"].has_key?("contactEmail") && !@data["meta"]["contactEmail"].blank?
          @data["meta"]["contactEmail"]
        end
      end

      def desc
        if @data["meta"].has_key?("allText") && !@data["meta"]["allText"].blank?
          @data["meta"]["allText"]
        elsif @data["meta"].has_key?("summary") && !@data["meta"]["summary"].blank?
          @data["meta"]["summary"]
        elsif @data.has_key?("summary") && !@data["summary"].blank?
          @data["summary"]
        else
          ""
        end
      end
      
      def user
        u = User.new
        u.email = @data["meta"]["contactEmail"] || nil
        u
      end
      
      # substitutionUrl could be formatted like this
      # 1. "meta":{"substitutionUrl":"vistarecreation/registrationmain.sdi?source=showAsset.sdi&activity_id=4900"}
      # 2. "meta":{"substitutionUrl":"4900"}
      def substitutionUrl
        if @data["meta"].has_key?("substitutionUrl")
          if /activity_id=/ =~ @data["meta"]["substitutionUrl"]
            @data["meta"]["substitutionUrl"].split("activity_id=")[1]
          else
            @data["meta"]["substitutionUrl"]
          end
        end
      end
      # TODO
      def activeworks_id
        0
      end
      def regcenter_id
        0
      end


    end
  end
end
