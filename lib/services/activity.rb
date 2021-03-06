require 'net/http'
require 'uri'
module Active
  module Services

    class ActivityFindError < StandardError; end

    class Activity < IActivity
      
      # EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65  reg
      # 3BF82BBE-CF88-4E8C-A56F-78F5CE87E4C6  reg2
      # FB27C928-54DB-4ECD-B42F-482FC3C8681F  ActiveNet US or Canada
      # 732A256E-2A25-4A02-81B3-769615CAA7A4  Active Net US or Canada
      # EC6E96A5-6900-4A0E-8B83-9AA935F45A73  Local
      # DFAA997A-D591-44CA-9FB7-BF4A4C8984F1  ActiveWorks
      
      # ecffc8b6-51ed-43af-82d3-540e607e5af5  Search Assets (This is a generic page (currently hosts Class Assets, Tournaments, and Swim Schools).  This data comes from ATS.)
      # 71D917DE-FA90-448A-90DA-C8852F7E03E2  tennislink.usta.com Tournaments (Tennis Tournaments, don’t know much about this one.)
      # 2b22b4e6-5aa4-44d7-bf06-f7a71f9fa8a6  AW Camps  (These are Foundations Camps pages.  They have a SOAP service.)
      # 2ba50aba-080e-4e3d-a01c-1b4f56648a2e  Asset Quality DB - Thriva (These are Thriva Camps.  This data come from ATS.)
      
      REG_CENTER_ASSET_TYPE_ID   = "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65"
      REG_CENTER_ASSET_TYPE_ID2  = "3BF82BBE-CF88-4E8C-A56F-78F5CE87E4C6"
      ACTIVE_WORKS_ASSET_TYPE_ID = "DFAA997A-D591-44CA-9FB7-BF4A4C8984F1"
      LOCAL_ASSET_TYPE_ID        = "EC6E96A5-6900-4A0E-8B83-9AA935F45A73"
      THRIVA                     = "2ba50aba-080e-4e3d-a01c-1b4f56648a2e"
      AW_CAMPS                   = "2b22b4e6-5aa4-44d7-bf06-f7a71f9fa8a6"
      TENNIS_TOURNAMENTS         = "71D917DE-FA90-448A-90DA-C8852F7E03E2"
      GENERIC_SEARCH             = "ecffc8b6-51ed-43af-82d3-540e607e5af5"
      
      attr_accessor :primary, :gsa, :ats
      attr_reader :datasources_loaded

      # data is a GSA object              
      def initialize(iactivity,preload_data=false)
        @datasources_loaded=false
        
        if iactivity.source==:gsa
          @gsa = iactivity
        elsif iactivity.source==:ats
          @ats = iactivity
        else
          @primary_source = iactivity
        end
        
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
      # todo remove
      def origin
        if @gsa.asset_type_id == REG_CENTER_ASSET_TYPE_ID || @gsa.asset_type_id == REG_CENTER_ASSET_TYPE_ID2
          return "RegCenter id= #{@gsa.asset_id} type= #{@gsa.asset_type_id}"
        elsif @gsa.asset_type_id == ACTIVE_WORKS_ASSET_TYPE_ID
          return "ActiveWorks id= #{@gsa.asset_id} type= #{@gsa.asset_type_id}"
        elsif @gsa.asset_type_id == LOCAL_ASSET_TYPE_ID
          return "Local id= #{@gsa.asset_id} type= #{@gsa.asset_type_id}"
        else
          return "Undefined id= #{@gsa.asset_id} type= #{@gsa.asset_type_id}"
        end 
      end
      
      def ats
        return @ats if @ats
        return @ats = ATS.find_by_id(asset_id)
      end

      def gsa
        return @gsa if @gsa
        s = Search.search({:asset_id=>asset_id, :start_date=>"01/01/2000"})
        if s.results.length > 0
          @gsa = s.results.first
        else
          nil
        end
        
      end
       
      def primary_source
        return @primary_source if @primary_source
        if asset_type_id == REG_CENTER_ASSET_TYPE_ID || asset_type_id == REG_CENTER_ASSET_TYPE_ID2   
          return @primary_source = RegCenter.find_by_id(substitutionUrl)
        elsif asset_type_id == ACTIVE_WORKS_ASSET_TYPE_ID
          return @primary_source = ActiveWorks.find_by_id(substitutionUrl)  
        end
      end
      # activity.rb:80: warning: else without rescue is useless
      # return true if @primary_source else false
      def primary_loaded?
        return true if @primary_source
        false
      end

      def ats_loaded?
        return true if @ats
        false
      end

      def gsa_loaded?
        return true if @gsa
        false
      end
      
      # def load_datasources
      #   return if @datasources_loaded==true
      #   
      #   @ats = ATS.find_by_id(@asset_id,true) if @ats==nil
      #   @ats.load_metadata
      #         @gsa = Search.search({:asset_id=>@asset_id, :start_date=>"01/01/2000"}).results.first if @gsa==nil
      # 
      #   if @primary==nil
      #     if @ats.asset_type_id==REG_CENTER_ASSET_TYPE_ID ||  @ats.asset_type_id==REG_CENTER_ASSET_TYPE_ID2
      #       @primary= RegCenter.find_by_id(@ats.substitutionUrl)
      #     elsif @ats.asset_type_id==ACTIVE_WORKS_ASSET_TYPE_ID
      #       @primary= ActiveWorks.find_by_id(@ats.substitutionUrl)
      #     end
      #   end
      #   @datasources_loaded=true
      # end

      def title
        return @primary_source.title if primary_loaded?
        return @ats.title if ats_loaded?
        return @gsa.title if gsa_loaded?
        return nil
      end
      
      def _title
        primary_source.title || ats.title || gsa.title || nil
      end
      
      def url
        return @primary_source.url if primary_loaded?
        return @ats.url if ats_loaded?
        return @gsa.url if  gsa_loaded?
        return nil
      end

      def _url
        #prefer seo a2 url first, then non seo a2 url, then primary url
        sources = [ats,primary_source,gsa]
        sources.each do |source|
          return source.url if source.url.downcase.index("www.active.com") && !source.url.downcase.index("detail")
        end
        sources.each do |source|
          return source.url if source.url.downcase.index("www.active.com")
        end
            
        return primary_source.url unless primary_source.nil?
        return ats.url     unless ats.nil?
        return gsa.url     unless gsa.nil?
        return nil
      end

      def categories
        return primary_source.categories if primary_loaded?
        return ats.categories     if ats_loaded?
        return gsa.categories     if gsa_loaded?
        return []
      end

      def _categories
        return primary_source.categories unless primary_source.nil?  || primary_source.categories.length==0
        return ats.categories     unless ats.nil? || ats.categories.length==0
        return gsa.categories     unless gsa.nil? || gsa.categories.length==0
        return []
      end

      def address
        return @primary_source.address if primary_loaded?
        return @ats.address     if ats_loaded?
        return @gsa.address     if gsa_loaded?
        return nil
      end

      def _address
        return primary_source.address unless primary_source.nil? || primary_source.address["address"].nil?
        return ats.address     unless ats.nil? || ats.address["address"].nil?
        return gsa.address     unless gsa.nil? || gsa.address["address"].nil?
        return nil
      end

      def start_date
        return @primary_source.start_date if primary_loaded?
        return @ats.start_date     if ats_loaded?
        return @gsa.start_date     if gsa_loaded?
        return nil
      end

      def _start_date
        return primary_source.start_date unless primary_source.nil? || primary_source.start_date.nil?
        return ats.start_date     unless ats.nil? || ats.start_date.nil?
        return gsa.start_date     unless gsa.nil? || gsa.start_date.nil?
        return nil
      end

      def start_time
        return @primary_source.start_time if primary_loaded?
        return @ats.start_time     if ats_loaded?
        return @gsa.start_time     if gsa_loaded?
        return nil
      end

      def _start_time
        return primary_source.start_time unless primary_source.nil? || primary_source.start_time.nil?
        return ats.start_time     unless ats.nil? || ats.start_time.nil?
        return gsa.start_time     unless gsa.nil? || gsa.start_time.nil?
        return nil
      end
      

      def end_date
        return @primary_source.end_date if primary_loaded?
        return @ats.end_date     if ats_loaded?
        return @gsa.end_date     if gsa_loaded?
        return nil
      end

      def _end_date
        return primary_source.end_date unless primary_source.nil? || primary_source.end_date.nil?
        return ats.end_date     unless ats.nil? || ats.end_date.nil?
        return gsa.end_date     unless gsa.nil? || gsa.end_date.nil?
        return nil
      end

      def end_time
        return @primary_source.end_time if primary_loaded?
        return @ats.end_time     if ats_loaded?
        return @gsa.end_time     if gsa_loaded?
        return nil
      end

      def _end_time
        return primary_source.end_time unless primary_source.nil? || primary_source.end_time.nil?
        return ats.end_time     unless ats.nil? || ats.end_time.nil?
        return gsa.end_time     unless gsa.nil? || gsa.end_time.nil?
        return nil
      end

      def category
        return @primary_source.category if primary_loaded?
        return @ats.category     if ats_loaded?
        return @gsa.category     if gsa_loaded?
        return nil
      end      

      def _category
        return primary_source.category unless primary_source.nil? || primary_source.category.nil?
        return ats.category     unless ats.nil? || ats.category.nil?
        return gsa.category     unless gsa.nil? || gsa.category.nil?
        return nil
      end

      def desc
        return @primary_source.desc if primary_loaded?
        return @ats.desc     if ats_loaded?
        return @gsa.desc     if gsa_loaded?
        return nil
      end      

      def _desc
        return primary_source.desc unless primary_source.nil? || primary_source.desc.nil?
        return ats.desc     unless ats.nil? || ats.desc.nil?
        return gsa.desc     unless gsa.nil? || gsa.desc.nil?
        return nil
      end

      def asset_id
        return @primary_source.asset_id if primary_loaded?
        return @ats.asset_id     if ats_loaded?
        return @gsa.asset_id     if gsa_loaded?
        return nil
      end

      def _asset_id
        return primary_source.asset_id unless primary_source.nil? || primary_source.asset_id.nil?
        return ats.asset_id     unless ats.nil? || ats.asset_id.nil?
        return gsa.asset_id     unless gsa.nil? || gsa.asset_id.nil?
        return nil
      end

      def asset_type_id
        return @primary_source.asset_type_id if primary_loaded?
        return @ats.asset_type_id     if ats_loaded?
        return @gsa.asset_type_id     if gsa_loaded?
        return nil
      end

      def _asset_type_id
        return primary_source.asset_type_id unless primary_source.nil? || primary_source.asset_type_id.nil?
        return ats.asset_type_id     unless ats.nil? || ats.asset_type_id.nil?
        return gsa.asset_type_id     unless gsa.nil? || gsa.asset_type_id.nil?
        return nil
      end
        
      # id within a system
      def asset_id=(value)        
        @gsa.asset_id
        # @asset_id = (value.class==Array) ? value[0] : value
      end
      # The asset type id lets us know what system is came from

      def online_registration
        if @gsa
          return @gsa.online_registration 
        else
          return false
        end
      end

      def primary_category
        return @primary.primary_category unless @primary.nil?
        load_datasources
        return @ats.primary_category     unless @ats.nil?
        return @gsa.primary_category     unless @gsa.nil?
        return @primary_category      if @primary_category
        return categories.first
      end
      
      def event_image_url
        
      end
      # def load_master
      #   # @ats = ATS.find_by_id(@gsa.asset_id)
      #   # throw StandardError.new "ATS type=#{@gsa.asset_type_id} id=#{@gsa.substitutionUrl}"
      #   # if @gsa.asset_type_id == REG_CENTER_ASSET_TYPE_ID || @gsa.asset_type_id == REG_CENTER_ASSET_TYPE_ID2
      #   #   throw StandardError.new "REG"
      #   # elsif @gsa.asset_type_id == ACTIVE_WORKS_ASSET_TYPE_ID
      #   #   throw StandardError.new "WORKS"
      #   # else
      #   #   throw StandardError.new @gsa.asset_type_id
      #   #   return false
      #   # end
      #   # if @ats.asset_type_id==REG_CENTER_ASSET_TYPE_ID ||  @ats.asset_type_id==REG_CENTER_ASSET_TYPE_ID2
      #   #   @primary= RegCenter.find_by_id(@ats.substitutionUrl)
      #   # elsif @ats.asset_type_id==ACTIVE_WORKS_ASSET_TYPE_ID
      #   #   @primary= ActiveWorks.find_by_id(@ats.substitutionUrl)
      #   # end
      #   
      # end

      # returns the best address possible from the data returned by the GSA
      #def address
#        @gsa.address
        # returned_address = validated_address({})
        # returned_address = @primary.address unless (@primary.nil? || @primary.address.nil?)
        # load_datasources
        # returned_address = @ats.address     unless @ats.nil?
        # returned_address = @gsa.address     
        # if @gsa.address[:address] != nil #and returned_address.city and returned_address.state and returned_address.country
        #   return returned_address
        # else          
        #   return nil
        # end
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
        # return returned_address
      #end
      # returns the best address possible by loading other data sources
      # 2. if the primary data source is unknow (ex asset_type_id is unknow ) we will return the GSA address.
      # 3. if no address but we have lat/lng we'll do a reverse look up
      def full_address
        @primary.address
        # 3.  MOVE TO A PRIVATE METHOD OR A NEW CLASS
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
      end
      
      def user
        return @gsa.user if !@gsa.nil?
        return @ats.user if !@ats.nil?
        return @primary.user if !@primary.nil?
      end

      def _user
        u            = User.new
        # If GSA doesn't have the email ATS should
        u.email      = @gsa.user.email      || ats.user.email || primary_source.user.email || nil
        # First name is only in ATS but GSA has a username that is kept in first_name
        u.first_name = ats.user.first_name  || @gsa.user.first_name || nil
        # Last name is only found in ATS
        u.last_name  = ats.user.last_name   || nil
        u
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

      
      def substitutionUrl
        return @gsa.substitutionUrl if !@gsa.nil?
        return @ats.substitutionUrl if !@ats.nil?
        return @primary.substitutionUrl if !@primary.nil?
        
        return nil
      end

      # reg-unavailable – No online registration
      # reg-not-open    – Online registration is available, but is not currently open
      # reg-closed      – The registration deadline has passed
      # reg-open        – Registration is currently open
      def regristration_status
        if @gsa.asset_type_id == "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65" 
          Net::HTTP.get URI.parse("http://apij.active.com/regcenter/event/#{@gsa.substitutionUrl}/regstatus")
        elsif @gsa.asset_type_id == "DFAA997A-D591-44CA-9FB7-BF4A4C8984F1"
          Net::HTTP.get URI.parse("http://apij.active.com/activeworks/event/#{@gsa.asset_id}/regstatus")
        else
          'reg-open'
        end
      end

      
      # Examples
      # Adding the asset type id will improve performance
      # Activity.find_by_asset_id(:asset_id => "A9EF9D79-F859-4443-A9BB-91E1833DF2D5", :asset_type_id => "EA4E860A-9DCD-4DAA-A7CA-4A77AD194F65")
      # Activity.find_by_asset_id(:asset_id => "A9EF9D79-F859-4443-A9BB-91E1833DF2D5")
      #
      def self.find(data)
        data = HashWithIndifferentAccess.new(data) || HashWithIndifferentAccess.new
        if data.has_key?(:substitutionUrl) and data.has_key?(:asset_type_id)
          puts "look up data form the original source"

          if data[:asset_type_id]==REG_CENTER_ASSET_TYPE_ID ||  data[:asset_type_id]==REG_CENTER_ASSET_TYPE_ID2
            return Activity.new(RegCenter.find_by_id(data[:substitutionUrl]))  
          elsif data[:asset_type_id]==ACTIVE_WORKS_ASSET_TYPE_ID
            return Activity.new(ActiveWorks.find_by_id(data[:substitutionUrl]))  
          else
            return Activity.new(ATS.find_by_id(@asset_id))  
          end
        elsif data.has_key?(:asset_id) 
          @asset_id = data[:asset_id]
          begin
            return Activity.new(ATS.find_by_id(@asset_id))  
          rescue ATSError => e
            raise ActivityFindError, "We could not find the activity with the asset_id of #{@asset_id}"
          end
        end
        raise ActivityFindError, "We could not find the activity with the asset_id of #{@asset_id}"

      end
      
    end
  end
end