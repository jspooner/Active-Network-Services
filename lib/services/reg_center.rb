module Active
  module Services

    class RegCenterError < StandardError;  end

    class RegCenter < IActivity
      require 'nokogiri'
      require 'open-uri'
      attr_accessor :asset_type_id
      
#      attr_reader :metadata_loaded
      # EXAMPLE Data hash
      # {:asset_id=>"A9EF9D79-F859-4443-A9BB-91E1833DF2D5", :substitution_url=>"1878023", :asset_type_name=>"Active.com Event Registration",
      # :asset_name=>"Fitness, Pilates  Mat Class (16 Yrs. &amp; Up)", :url=>"http://www.active.com/page/Event_Details.htm?event_id=1878023",
      # :asset_type_id=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", :xmlns=>"http://api.asset.services.active.com"}

      def initialize(data={})
        # need to hold on to original data
        @data = HashWithIndifferentAccess.new(data) || HashWithIndifferentAccess.new
        @api_data_loaded = false
        @asset_type_id = "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65"
        get_app_api
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
        if @data.has_key?("event") && @data["event"].has_key?("registrationUrl")
          @data["event"]["registrationUrl"]
        end
      end
      
      def categories
        if @data["event"]["channels"]["channel"]!=nil
          @data["event"]["channels"]["channel"].collect {|e| e["channelName"]}          
        end
      end
      
      def primary_category
        if @data["event"]["channels"]["channel"]!=nil
          @data["event"]["channels"]["channel"].each do |c|
            return c["channelName"] if c.has_key?("primaryChannel")
          end  
        end
      end

      def address
        if @data.has_key?("event") && @data["event"].has_key?("eventAddress") && !@data["event"]["eventAddress"].blank?
          @address = {
            :name    => @data["event"]["eventLocation"],
            :address => @data["event"]["eventAddress"],
            :city    => @data["event"]["eventCity"],
            :state   => @data["event"]["eventState"],
            :zip     => @data["event"]["eventZip"],
            :lat     => @data["event"]["latitude"],
            :lng     => @data["event"]["longitude"],
            :country => @data["event"]["eventCountry"]
          }        
        end
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

      def category
        primary_category
      end

      def desc
        if @data.has_key?("event") && @data["event"].has_key?("briefDescription")
          ret=@data["event"]["briefDescription"]
          if data["event"].has_key?("eventDetails")
            data["event"]["eventDetails"]["eventDetail"].each do |detail|
              ret +="<div><b>" + detail["eventDetailsName"] + ":</b> " + cleanup_reg_string(detail["eventDetailsValue"]) + "</div>"
            end
          end
          ret
        end
      end
      
      def cleanup_reg_string(input)
        input.gsub("\r","").gsub("\n","").gsub("\"","""").gsub("\342\200\234","""").gsub("\342\200\235","""")
      end


      # EXAMPLE
      # lazy load the data for some_crazy_method
      # def some_crazy
      #   return @some_crazy unless @some_crazy.nil?
      #   @some_crazy = @data[:some_crazy_method_from_ats].split replace twist bla bla bla
      # end

      def self.find_by_id(id) #local id
          return RegCenter.new({:id=>id})
      end

      private
      # def self.get_asset_metadata(id)
      #   c = Savon::Client.new("http://api.amp.active.com/asset-service/services/AssetService?wsdl")
      #   c.request.headers["Api-Key"] = "6npky9t57235vps5cetm3s7k"
      #   r = c.get_asset_metadata do |soap|
      #     soap.namespace = "http://api.asset.services.active.com"
      #     soap.body = "<context><userId></userId><applicationId></applicationId></context><assetId>#{id}</assetId>"
      #   end
      #   puts "==========="
      #   puts r.to_hash[:get_asset_metadata_response][:out].inspect
      #   return r
      # end
      # 
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
      
      def get_app_api
        puts "loading reg center api"
        begin
          doc = Nokogiri::XML(open("http://apij.active.com/regcenter/event/#{@data[:id]}"))
          @data.merge! Hash.from_xml doc.to_s
          @api_data_loaded=true
        rescue
          raise RegCenterError, "Couldn't find Reg Center activity with the id of #{id}"
          return
        end
      end

    end # end ats
  end
end
