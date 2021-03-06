module Active
  module Services

    class RegCenterError < StandardError;  end

    class RegCenter < IActivity
      require 'nokogiri'
      require 'open-uri'
      require 'digest/sha1'
      attr_accessor :asset_type_id
      
#      attr_reader :metadata_loaded
      # EXAMPLE Data hash
      # {:asset_id=>"A9EF9D79-F859-4443-A9BB-91E1833DF2D5", :substitution_url=>"1878023", :asset_type_name=>"Active.com Event Registration",
      # :asset_name=>"Fitness, Pilates  Mat Class (16 Yrs. &amp; Up)", :url=>"http://www.active.com/page/Event_Details.htm?event_id=1878023",
      # :asset_type_id=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", :xmlns=>"http://api.asset.services.active.com"}

      def initialize(data={})
        @data = HashWithIndifferentAccess.new(data) || HashWithIndifferentAccess.new
        @asset_type_id = "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65"
      end

      def source
        :reg_center
      end

      def title
        if @data.has_key?("event") && @data["event"].has_key?("eventName")
          cleanup_reg_string(@data["event"]["eventName"])
        end
      end
      
      def event_image_url
        if @data.has_key?("event") && @data["event"].has_key?("eventImageUrl")
          @data["event"]["eventImageUrl"]
        end
      end

      def url
        if @data.has_key?("event") && @data["event"].has_key?("eventDetailsPageUrl")
          @data["event"]["eventDetailsPageUrl"]
        elsif @data.has_key?("event") && @data["event"].has_key?("registrationUrl")
          @data["event"]["registrationUrl"]
        elsif @data.has_key?("event") && @data["event"].has_key?("eventContactUrl")
          @data["event"]["eventContactUrl"]
        end
      end
      
      def registration_url
        if @data.has_key?("event") && @data["event"].has_key?("registrationUrl")
          @data["event"]["registrationUrl"]
        else
          ""
        end
      end
      
      def event_url
        @data[:event][:eventUrl]
      end
      
      def categories
        if @data.has_key?("event") && @data["event"].has_key?("channels") && @data["event"]["channels"]!=nil && @data["event"]["channels"].has_key?("channel") && @data["event"]["channels"]["channel"]!=nil
          channels = @data["event"]["channels"]["channel"]
          if channels.class==Array
            @data["event"]["channels"]["channel"].collect {|e| e["channelName"]}          
          else
            #hash
            [channels["channelName"]]
          end
        end
      end
      
      def asset_id
        if @data.has_key?("event") && @data["event"].has_key?("assetID")
          @data["event"]["assetID"]
        end
      end
      
      def primary_category
        if @data["event"]["channels"]["channel"]!=nil
          channels = @data["event"]["channels"]["channel"]
          if channels.class==Array
            channels.each do |c|
              return c["channelName"] if c.has_key?("primaryChannel") && c["primaryChannel"]=="true"
            end
            nil
          else
            #hash
            return channels["channelName"] if channels.has_key?("primaryChannel") && channels["primaryChannel"]=="true"
            return nil
          end
        end
      end

      def address
        @address = validated_address({
          :name    => @data["event"]["eventLocation"],
          :address => @data["event"]["eventAddress"],
          :city    => @data["event"]["eventCity"],
          :state   => @data["event"]["eventState"],
          :zip     => @data["event"]["eventZip"],
          :lat     => @data["event"]["latitude"],
          :lng     => @data["event"]["longitude"],
          :country => @data["event"]["eventCountry"]
        } )
      end

      def start_date
        DateTime.parse @data["event"]["eventDate"] if @data.has_key?("event") && @data["event"].has_key?("eventDate")
      end

      def start_time
        start_date
      end

      def end_time
        nil
      end

      def end_date
        nil
      end
      # The date and time that registration closes
      def registration_close_date
        DateTime.parse(@data["event"]["eventCloseDate"])
      end

      def category
        primary_category
      end
      
      def user
        email        = contact_email
        u            = User.new
        u.email      = email if Validators.email(email)
#        u.first_name = @data["meta"]["contactName"] || nil
#        u.phone      = @data["meta"]["contactPhone"] || nil
        u
      end

      def desc_old
        if @data.has_key?("event") && @data["event"].has_key?("briefDescription")
          ret = @data["event"]["briefDescription"]
          if @data["event"].has_key?("eventDetails")  && @data["event"]["eventDetails"] != nil && @data["event"]["eventDetails"].has_key?("eventDetail")
            eventDetail = @data["event"]["eventDetails"]["eventDetail"]
            if eventDetail.class == Array
              @data["event"]["eventDetails"]["eventDetail"].each do |detail|
                ret +="<div><b>" + detail["eventDetailsName"] + ":</b> " + cleanup_reg_string(detail["eventDetailsValue"]) + "</div>"
              end
            else
              #hash
              ret +="<div><b>" + eventDetail["eventDetailsName"] + ":</b> " + cleanup_reg_string(eventDetail["eventDetailsValue"]) + "</div>"
            end
          end
          return ret
        elsif @data.has_key?("event") && @data["event"].has_key?("eventDescription")
          return @data["event"]["eventDescription"]
        end
      end
      
      def desc(length = :full)
        if length == :full
          @data["event"]["eventDescription"]
        else
          @data["event"]["briefDescription"]
        end
      end
      
      # Content should be a array of hashes.
      # [ {:title => "briefDescription", :type => "html", :content => "..." }]
      #
      # It should contain everything in briefDescription description and eventDetails.
      # It should just be one big happy 
      # 
      # TODO: Need to order this by detail[:eventDetailsOrder]
      # TODO: Add the other description blocks to this 
      def content
        if @data["event"] and @data["event"]["eventDetails"] 

          if @data["event"]["eventDetails"]["eventDetail"].class == Array
            return @data["event"]["eventDetails"]["eventDetail"].collect { |obj| {:title => obj[:eventDetailsName], :content => obj[:eventDetailsValue]} } 
          else
            return [{:title => @data["event"]["eventDetails"]["eventDetail"]["eventDetailsName"],:content => @data["event"]["eventDetails"]["eventDetail"]["eventDetailsValue"]}]
          end
          
        else
          return []
        end
      end
      
      def cleanup_reg_string(input)
        input.gsub("\r","").gsub("\n","").gsub("\"","""").gsub("\342\200\234","""").gsub("\342\200\235","""")
      end

      def contact_email
        if @data.has_key?("event") && @data["event"].has_key?("eventContactEmail")
          return @data["event"]["eventContactEmail"]
        end
      end


      # EXAMPLE
      # lazy load the data for some_crazy_method
      # def some_crazy
      #   return @some_crazy unless @some_crazy.nil?
      #   @some_crazy = @data[:some_crazy_method_from_ats].split replace twist bla bla bla
      # end
      # local id
      def self.find_by_id(id) 
        begin
          doc  = Nokogiri::XML(open("http://apij.active.com/regcenter/event/#{id}"))
          puts "////////<br/>"
          puts doc.to_s
          puts "////////<br/>"
          reg  = RegCenter.new(Hash.from_xml(doc.to_s))
        rescue Exception => e
          raise RegCenterError, "Couldn't find Reg Center activity with the id of #{id} - #{e.inspect}"
          return nil
        end
        reg
      end


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


      private
      # def self.get_asset_by_id(id)
      #   puts "loading ATS"
      #   c = Savon::Client.new("http://api.amp.active.com/asset-service/services/AssetService")
      #   c.request.headers["Api-Key"] = "6npky9t57235vps5cetm3s7k"
      #   r = c.get_asset_by_id! do |soap|
      #     soap.namespace = "http://api.asset.services.active.com"
      #     soap.body = "<context><userId></userId><applicationId></applicationId></context><assetId>#{id}</assetId>"
      #   end
      #   return r
      # end
      # 
      # def load_metadata
      #   puts "loading ATS metadata"
      #   metadata = ATS.get_asset_metadata(@asset_id)
      #   @data.merge! Hash.from_xml(metadata.to_hash[:get_asset_metadata_response][:out])["importSource"]["asset"]
      #   @metadata_loaded=true
      # end
      
      # def get_app_api
      #   puts "loading reg center api"
      #   begin
      #     doc = Nokogiri::XML(open("http://apij.active.com/regcenter/event/#{@data[:id]}"))
      #     @data.merge! Hash.from_xml doc.to_s
      #     @api_data_loaded=true
      #   rescue
      #     raise RegCenterError, "Couldn't find Reg Center activity with the id of #{id}"
      #     return
      #   end
      # end

    end # end ats
  end
end
