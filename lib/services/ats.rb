module Active
  module Services

    class ATSError < StandardError;  end

    class ATS < IActivity

      attr_reader :metadata_loaded
      # EXAMPLE Data hash
      # {"destinationID"=>"", "assetId"=>"A9EF9D79-F859-4443-A9BB-91E1833DF2D5", "substitutionUrl"=>"1878023", "city"=>"Antioch", "contactName"=>"City of Antioch", "trackbackurl"=>"http://www.active.com/page/Event_Details.htm?event_id=1878023&assetId=A9EF9D79-F859-4443-A9BB-91E1833DF2D5", "category"=>"Activities", "zip"=>"94531", "userCommentText"=>nil, "location"=>"Multi-use Room (prewett) - Prewett Family Park & Center", "latitude"=>"37.95761", :asset_id=>"A9EF9D79-F859-4443-A9BB-91E1833DF2D5", "searchWeight"=>"1", "country"=>"United States", "participationCriteria"=>"All", "dma"=>"San Francisco - Oakland - San Jose", "isSearchable"=>"true", :asset_name=>"Fitness, Pilates  Mat Class (16 Yrs. &amp; Up)", :substitution_url=>"1878023", :asset_type_id=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", "row"=>"1", "image1"=>"http://www.active.com/images/events/hotrace.gif", "startDate"=>"2010-09-13", "contactPhone"=>"925-779-7070", :asset_type_name=>"Active.com Event Registration", "onlineDonationAvailable"=>"0", "avgUserRating"=>nil, "market"=>"San Francisco - Oakland - San Jose", "assetTypeId"=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", "assetName"=>"Fitness, Pilates  Mat Class (16 Yrs. & Up)", "channel"=>"Not Specified", "seourl"=>"http://www.active.com/not-specified-recware-activities/antioch-ca/fitness-pilates-mat-class-16-yrs-and-up-2010", :xmlns=>"http://api.asset.services.active.com", :url=>"http://www.active.com/page/Event_Details.htm?event_id=1878023", "mediaType"=>"Recware Activities", "startTime"=>"18:15:00", "endTime"=>"18:15:00", "contactEmail"=>"dadams@ci.antioch.ca.us", "eventResults"=>nil, "longitude"=>"-121.7936", "endDate"=>"2010-09-13", "onlineRegistrationAvailable"=>"true", "onlineMembershipAvailable"=>"0", "state"=>"California"}
      # {"destinationID"=>"", "assetId"=>"D9A22F33-8A14-4175-8D5B-D11578212A98", "substitutionUrl"=>"1847738", "city"=>"Encino", "contactName"=>"Lilliane Ballesteros", "trackbackurl"=>"http://www.active.com/page/Event_Details.htm?event_id=1847738&assetId=D9A22F33-8A14-4175-8D5B-D11578212A98", "category"=>"Activities", "zip"=>"91406", "userCommentText"=>nil, "location"=>"Balboa Park/Lake Balboa", "latitude"=>"34.19933", :asset_id=>"D9A22F33-8A14-4175-8D5B-D11578212A98", "searchWeight"=>"1", "country"=>"United States", "participationCriteria"=>"All", "dma"=>"Los Angeles", "isSearchable"=>"1", :asset_name=>"2nd Annual weSPARK 10K Run &amp; 5K Run Walk", :substitution_url=>"1847738", :asset_type_id=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", "row"=>"1", "image1"=>"http://www.active.com/images/events/hotrace.gif", "startDate"=>"2010-11-14", "contactPhone"=>"818-906-3022", :asset_type_name=>"Active.com Event Registration", "onlineDonationAvailable"=>"0", "avgUserRating"=>nil, "market"=>"Los Angeles", "assetTypeId"=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", "assetName"=>"2nd Annual weSPARK 10K Run & 5K Run Walk", "channel"=>["Running", "Walking"], "seourl"=>"http://www.active.com/running/encino-ca/2nd-annual-wespark-10k-run-and-5k-run-walk-2010", :xmlns=>"http://api.asset.services.active.com", :url=>"http://www.active.com/page/Event_Details.htm?event_id=1847738", "mediaType"=>["Event", "Event\\10K", "Event\\5K"], "startTime"=>"8:00:00", "endTime"=>"8:00:00", "contactEmail"=>"lilliane@wespark.org", "eventResults"=>nil, "longitude"=>"-118.4924", "endDate"=>"2010-11-14", "onlineRegistrationAvailable"=>"1", "onlineMembershipAvailable"=>"0", "state"=>"California", "estParticipants"=>"1400", "eventURL"=>"http://www.wespark.org"}

      def initialize(data={})
        # need to hold on to original data
        @data = data || {}
        @asset_id      = data[:asset_id]
        @url           = data[:url]
        @asset_type_id = data[:asset_type_id]
        @title         = data[:asset_name] if data[:asset_name]
        @substitution_url = data[:substitution_url]
        @metadata_loaded = false
      end

      def source
        :ats
      end


      def title
        load_metadata unless @metadata_loaded
        if @data.has_key?("assetName")
          @data["assetName"]
        else
          @title
        end
      end

      def url
        load_metadata unless @metadata_loaded
        if @data.has_key?("seourl")
          @data["seourl"]
        elsif @data.has_key?("trackbackurl")
          @data["trackbackurl"]
        else
          @url
        end
      end

      def categories
        load_metadata unless @metadata_loaded
        categories = @data["channel"]
        if categories.class==String
          [@data["channel"]]
        else
          @data["channel"]
        end
      end

      def address
        load_metadata unless @metadata_loaded
        @address = {
          :name    => @data["location"],
          :address => @data["address"],
          :city    => @data["city"],
          :state   => @data["state"],
          :zip     => @data["zip"],
          :lat     => @data["latitude"],
          :lng     => @data["longitude"],
          :country => @data["country"]
        }
      end

      def start_date
        load_metadata unless @metadata_loaded
        if @data.has_key?("startDate")
          if @data.has_key?("startTime")
            (DateTime.parse "#{@data["startDate"]} #{@data["startTime"]}")
          else
            (DateTime.parse @data["startDate"])
          end
        else
          nil
        end
      end

      def start_time
        start_date
      end

      def end_date
        load_metadata unless @metadata_loaded
        if @data.has_key?("endDate")
          if @data.has_key?("endTime")
            (DateTime.parse "#{@data["endDate"]} #{@data["endTime"]}")
          else
            (DateTime.parse @data["endDate"])
          end
        else
          nil
        end
      end

      def end_time
        end_date
      end


      def category
        categories.first
      end

      def desc
        load_metadata unless @metadata_loaded
        if @data.has_key?("allText")
          @data["allText"]
        elsif @data.has_key?("summary")
          @data["summary"]
        end
      end
      
      def contact_name
        load_metadata unless @metadata_loaded
        @data["contactName"] if @data.has_key?("contactName")
      end

      def contact_email
        load_metadata unless @metadata_loaded
        @data["contactEmail"] if @data.has_key?("contactEmail")
      end


      # EXAMPLE
      # lazy load the data for some_crazy_method
      # def some_crazy
      #   return @some_crazy unless @some_crazy.nil?
      #   @some_crazy = @data[:some_crazy_method_from_ats].split replace twist bla bla bla
      # end

      def self.find_by_id(id)
        begin
          r = self.get_asset_by_id(id)
          return ATS.new(r.to_hash[:get_asset_by_id_response][:out])
        rescue Savon::SOAPFault => e
          raise ATSError, "Couldn't find activity with the id of #{id}"
          return
        end
      end

      private
      def self.get_asset_metadata(id)
        c = Savon::Client.new("http://api.amp.active.com/asset-service/services/AssetService?wsdl")
        c.request.headers["Api-Key"] = "6npky9t57235vps5cetm3s7k"
        r = c.get_asset_metadata do |soap|
          soap.namespace = "http://api.asset.services.active.com"
          soap.body = "<context><userId></userId><applicationId></applicationId></context><assetId>#{id}</assetId>"
        end
        puts "==========="
        puts r.to_hash[:get_asset_metadata_response][:out].inspect
        return r
      end

      def self.get_asset_by_id(id)
        c = Savon::Client.new("http://api.amp.active.com/asset-service/services/AssetService")
        c.request.headers["Api-Key"] = "6npky9t57235vps5cetm3s7k"
        r = c.get_asset_by_id! do |soap|
          soap.namespace = "http://api.asset.services.active.com"
          soap.body = "<context><userId></userId><applicationId></applicationId></context><assetId>#{id}</assetId>"
        end
        return r
      end

      def load_metadata
        metadata = ATS.get_asset_metadata(@asset_id)
        @data.merge! Hash.from_xml(metadata.to_hash[:get_asset_metadata_response][:out])["importSource"]["asset"]
        @metadata_loaded=true
      end

    end # end ats
  end
end
