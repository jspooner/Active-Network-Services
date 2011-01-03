require 'nokogiri'
require 'open-uri'

module Active
  module Services

    class ActiveWorksError < StandardError;  end

    class ActiveWorks < IActivity
      
      attr_accessor :asset_type_id
      
      def initialize(data={})
        # need to hold on to original data
        @data = HashWithIndifferentAccess.new(data) || HashWithIndifferentAccess.new
        @api_data_loaded = false
        @asset_type_id = "DFAA997A-D591-44CA-9FB7-BF4A4C8984F1"
        get_app_api
      end

      def source
        :active_works
      end
      
      def asset_id
        if @data.has_key?("eventDetailDto") && @data["eventDetailDto"].has_key?("id")
          @data["eventDetailDto"]["id"]
        end
      end
      

      def title
        if @data.has_key?("eventDetailDto") && @data["eventDetailDto"].has_key?("name")
          @data["eventDetailDto"]["name"]
        end
      end
      
      def event_image_url
        if @data.has_key?("eventDetailDto") && @data["eventDetailDto"].has_key?("logoUrl")
          @data["eventDetailDto"]["logoUrl"]
        end
      end

      def url
        if @data.has_key?("eventDetailDto") && @data["eventDetailDto"].has_key?("registrationUrl")
          @data["eventDetailDto"]["registrationUrl"]
        end
      end
      
      def categories
        [@data["eventDetailDto"]["channels"]]
      end
      
      def primary_category
        categories.first
      end

      def address
          @address = validated_address({
            :address => @data["eventDetailDto"]["addressLine1"],
            :city    => @data["eventDetailDto"]["addressCity"],
            :state   => @data["eventDetailDto"]["state"],
            :zip     => @data["eventDetailDto"]["addressPostalCode"],
            :country => @data["eventDetailDto"]["countryName"]
          })
      end

      def start_date
        DateTime.parse @data["eventDetailDto"]["startDateTimeWithTZ"] if @data.has_key?("eventDetailDto") && @data["eventDetailDto"].has_key?("startDateTimeWithTZ")
      end

      def start_time
        start_date
      end

      def end_date
        DateTime.parse @data["eventDetailDto"]["endDateTime"] if @data.has_key?("eventDetailDto") && @data["eventDetailDto"].has_key?("endDateTime")
      end

      def end_time
        end_date
      end
      
      def contact_name
        nil
      end

      def contact_email
        nil
      end
      
      def user
        User.new
      end


      def category
        primary_category
      end

      def desc
        if @data.has_key?("eventDetailDto") && @data["eventDetailDto"].has_key?("description")
#          @data["eventDetailDto"]["description"].gsub('\"','"')
          sanitize @data["eventDetailDto"]["description"]
        end
      end
      

      # EXAMPLE
      # lazy load the data for some_crazy_method
      # def some_crazy
      #   return @some_crazy unless @some_crazy.nil?
      #   @some_crazy = @data[:some_crazy_method_from_ats].split replace twist bla bla bla
      # end

      def self.find_by_id(id) #local id
          return ActiveWorks.new({:id=>id})
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
#        puts "loading active works api"
        begin
          doc = Nokogiri::XML(open("http://apij.active.com/activeworks/event/#{@data[:id]}"))
          @data.merge! Hash.from_xml doc.to_s
          @api_data_loaded=true
        rescue
          raise ActiveWorksError, "Couldn't find ActiveWorks activity with the id of #{id}"
          return
        end
      end

    end # end ats
  end
end
