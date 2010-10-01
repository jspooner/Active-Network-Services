module Active
  module Services

    class ActivityFindError < StandardError; end

    class Activity < IActivity
      REG_CENTER_ASSET_TYPE_ID="EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65"
      REG_CENTER_ASSET_TYPE_ID2="3BF82BBE-CF88-4E8C-A56F-78F5CE87E4C6"
      ACTIVE_WORKS_ASSET_TYPE_ID="DFAA997A-D591-44CA-9FB7-BF4A4C8984F1"

      attr_accessor :primary, :gsa, :ats
      attr_reader :datasources_loaded

      # data is a GSA object              
      def initialize(gsa,preload_data=false)
        @datasources_loaded=false
        
        @gsa = gsa
        
        # if data.respond_to?('source')
        #   @ats     = gsa if data.source == :ats
        #   @gsa     = gsa if data['source'] == :gsa
        #   @primary = gsa if data.source == :primary
        #   
        #   @asset_id = @ats.asset_id if @ats!=nil
        #   @asset_id = @gsa.asset_id if @gsa!=nil
        #   @asset_id = @primary.asset_id if @primary!=nil
        #   
        #   load_datasources if preload_data
        # end
      end
      
      def source
        :active
      end
      
      def load_datasources
        return if @datasources_loaded==true
        
        @ats = ATS.find_by_id(@asset_id,true) if @ats==nil
        @ats.load_metadata
    		@gsa = Search.search({:asset_id=>@asset_id, :start_date=>"01/01/2000"}).results.first if @gsa==nil

        if @primary==nil
          if @ats.asset_type_id==REG_CENTER_ASSET_TYPE_ID ||  @ats.asset_type_id==REG_CENTER_ASSET_TYPE_ID2
            @primary= RegCenter.find_by_id(@ats.substitutionUrl)
          elsif @ats.asset_type_id==ACTIVE_WORKS_ASSET_TYPE_ID
            @primary= ActiveWorks.find_by_id(@ats.substitutionUrl)
          end
        end
        @datasources_loaded=true
      end

      def title
        return @gsa.title unless @gsa.nil?
        return nil
      end

      # id within a system
      def asset_id=(value)        
        @gsa.asset_id
        # @asset_id = (value.class==Array) ? value[0] : value
      end
      # The asset type id lets us know what system is came from
      def asset_type_id
        return @gsa.asset_type_id     unless @gsa.nil?
        return nil
      end

      def url
        #prefer seo a2 url first, then non seo a2 url, then primary url
        load_datasources
        sources = [@ats,@primary,@gsa]
        sources.each do |source|
          return source.url if source.url.downcase.index("www.active.com") && !source.url.downcase.index("detail")
        end
        sources.each do |source|
          return source.url if source.url.downcase.index("www.active.com")
        end
            
        return @primary.url unless @primary.nil?
        return @ats.url     unless @ats.nil?
        return @gsa.url     unless @gsa.nil?
        return @url      if @url
        return nil
      end

      def categories
        return @primary.categories unless @primary.nil?
        load_datasources
        return @ats.categories     unless @ats.nil?
        return @gsa.categories     unless @gsa.nil?
        return @categories      if @categories
        return []
      end

      def asset_id
        return @gsa.asset_id     unless @gsa.nil?
        return nil
      end

      def primary_category
        return @primary.primary_category unless @primary.nil?
        load_datasources
        return @ats.primary_category     unless @ats.nil?
        return @gsa.primary_category     unless @gsa.nil?
        return @primary_category      if @primary_category
        return categories.first
      end

      def address
        # returned_address = validated_address({})
        # returned_address = @primary.address unless (@primary.nil? || @primary.address.nil?)
        # load_datasources
        # returned_address = @ats.address     unless @ats.nil?
        returned_address = @gsa.address     unless @gsa.nil?
        # returned_address =  @address        if @address
        # 
        # #ensure lat/lng
        # if (returned_address["lat"]=="")
        #   load_datasources
        #   if @primary.address["lat"]!=""
        #     returned_address["lat"] = @primary.address["lat"] 
        #     returned_address["lng"] = @primary.address["lng"] 
        #   elsif @ats.address["lat"]!=""
        #     returned_address["lat"] = @ats.address["lat"] 
        #     returned_address["lng"] = @ats.address["lng"] 
        #   elsif @gsa.address["lat"]!=""
        #     returned_address["lat"] = @gsa.address["lat"] 
        #     returned_address["lng"] = @gsa.address["lng"] 
        #   end
        # end
        # 
        # if (returned_address["lat"]=="")
        #   #geocode
        #   geocode_url=""
        #   if returned_address["zip"]!="" && returned_address["zip"]!="00000"
        #     geocode_url="http://api.active.com/Rest/addressvalidator/Handler.ashx?z=#{returned_address["zip"]}"
        #   elsif returned_address["city"]!="" && returned_address["state"]!=""
        #     geocode_url="http://api.active.com/Rest/addressvalidator/Handler.ashx?c=#{returned_address["city"]}&s=#{returned_address["state"]}"
        #   end
        #   puts "geocode_url: #{geocode_url}"
        #   if geocode_url!=""
        #     require 'open-uri'
        #     begin
        #       Nokogiri::XML(open(geocode_url)).root.children.each do |node|
        #         returned_address["lat"]=node.content if node.name=="Latitude"
        #         returned_address["lng"]=node.content if node.name=="Longitude"
        #         returned_address["city"]=Validators.valid_state(node.content) if node.name=="City" && returned_address["city"]==""
        #         returned_address["zip"]=node.content if node.name=="ZipCode" && returned_address["zip"]==""
        #         returned_address["state"]=node.content if node.name=="StateCode" && returned_address["state"]==""
        #       end
        #     rescue 
        #       puts { "[GEO ERROR] #{geocode_url}" }
        #     end
        #     
        #   end
        # end

        return returned_address
      end

      def start_date
        return @gsa.start_date     unless @gsa.nil?
        return nil
      end

      def start_time
        return @gsa.start_time     unless @gsa.nil?
        return nil
      end

      def end_date
        return @gsa.end_date     unless @gsa.nil?
        return nil
      end

      def end_time
        return @gsa.end_time     unless @gsa.nil?
        return nil
      end

      def category
        return @primary.category unless @primary.nil?
        load_datasources
        return @ats.category     unless @ats.nil?
        return @gsa.category     unless @gsa.nil?
        return @category      if @category
        primary_category
      end

      def contact_name
        return @primary.contact_name unless @primary.nil?
        load_datasources
        return @ats.contact_name     unless @ats.nil?
        return @gsa.contact_name     unless @gsa.nil?
        return @contact_name      if @contact_name
        return nil
      end

      def contact_email
        return @primary.contact_email unless @primary.nil?
        load_datasources
        return @ats.contact_email     unless @ats.nil?
        return @gsa.contact_email     unless @gsa.nil?
        return @contact_email      if @contact_email
        return nil
      end

      def desc
        return @primary.desc unless @primary.nil?
        load_datasources
        return @ats.desc     unless @ats.nil?
        return @gsa.desc     unless @gsa.nil?
        return @desc      if @desc
        return nil
      end
      
      def substitutionUrl
        return @primary.substitutionUrl unless @primary.nil?
        load_datasources
        return @ats.substitutionUrl     unless @ats.nil?
        return @gsa.substitutionUrl     unless @gsa.nil?
        return @substitutionUrl      if @substitutionUrl
        return nil
      end

      
      # Examples
      # Adding the asset type id will improve performance
      # Activity.find_by_asset_id(:asset_id => "A9EF9D79-F859-4443-A9BB-91E1833DF2D5", :asset_type_id => "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65")
      # Activity.find_by_asset_id(:asset_id => "A9EF9D79-F859-4443-A9BB-91E1833DF2D5")
      #
      def self.find_by_asset_id(data)
        if data.has_key?(:asset_id) and data.has_key?(:asset_type_id) == false
          @asset_id = data[:asset_id]
          begin
            return Activity.new(ATS.find_by_id(@asset_id))  
          rescue ATSError => e
            raise ActivityFindError, "We could not find the activity with the asset_id of #{@asset_id}"
          end
        elsif data.has_key?(:substitutionUrl) and data.has_key?(:asset_type_id)
          puts "look up data form the original source"

          if data[:asset_type_id]==REG_CENTER_ASSET_TYPE_ID ||  data[:asset_type_id]==REG_CENTER_ASSET_TYPE_ID2
            return Activity.new(RegCenter.find_by_id(data[:substitutionUrl]))  
          elsif data[:asset_type_id]==ACTIVE_WORKS_ASSET_TYPE_ID
            return Activity.new(ActiveWorks.find_by_id(data[:substitutionUrl]))  
          end

        end
        raise ActivityFindError, "We could not find the activity with the asset_id of #{@asset_id}"

      end
      
    end
  end
end