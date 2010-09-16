module Active
  module Services

    class ATSError < StandardError;  end

    class ATS < IActivity

      attr_reader :metadata_loaded
      # EXAMPLE Data hash
      # {:asset_id=>"A9EF9D79-F859-4443-A9BB-91E1833DF2D5", :substitution_url=>"1878023", :asset_type_name=>"Active.com Event Registration",
      # :asset_name=>"Fitness, Pilates  Mat Class (16 Yrs. &amp; Up)", :url=>"http://www.active.com/page/Event_Details.htm?event_id=1878023",
      # :asset_type_id=>"EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65", :xmlns=>"http://api.asset.services.active.com"}

      def initialize(data={})
        # need to hold on to original data
        @data = data || {}
        @asset_id      = data[:asset_id]
        @url           = data[:url]
        @asset_id_type = data[:asset_type_id]
        @title         = data[:asset_name] if data[:asset_name]
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
        @data["channel"]
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
        DateTime.parse @data["startDate"] if @data.has_key? ("startDate")
      end

      def start_time
        load_metadata unless @metadata_loaded
        @data["startTime"]
      end

      def end_time
        load_metadata unless @metadata_loaded
        @data["endTime"]
      end

      def end_date
        load_metadata unless @metadata_loaded
        DateTime.parse @data["endDate"] if @data.has_key? ("endDate")
      end

      def category
        load_metadata unless @metadata_loaded
        @data["channel"]
      end

      def desc
        load_metadata unless @metadata_loaded
        if @data.has_key? ("allText")
          @data["allText"]
        elsif @data.has_key? ("summary")
          @data["summary"]
        end
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
