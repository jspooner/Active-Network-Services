require 'net/http'
require 'json'
require 'cgi'
require 'mysql' 
require 'active_record'
require 'digest/md5'

module Active
  module Services
    
    # we should remove this class and just replace with symbols
    class Sort
      def self.DATE_ASC 
        "date_asc"
      end
      def self.DATE_DESC
        "date_desc"
      end
      def self.RELEVANCE
        "relevance"
      end
    end

    # we should remove this class and just replace with symbols    
    class Facet
      def self.ACTIVITIES
        "activities"
      end
    end

    class Search
      attr_accessor :api_key, :start_date, :end_date, :location, :channels, :split_media_type, :keywords, :search, :radius, :limit, :sort, :page, :offset, :latitude, :longitude,
                    :asset_type_id, :url,
                    :view, :facet, :sort, :num_results, :asset_ids, :dma, :city, :state, :country, :bounding_box
                    
      attr_reader :results, :endIndex, :pageSize, :searchTime, :numberOfResults, :end_point, :meta
       
      SEARCH_URL      = "http://search.active.com"
      DEFAULT_TIMEOUT = 60
      
      def initialize(data={})
        self.asset_type_id    = data[:asset_type_id]
        self.url              = data[:url]
        self.api_key          = data[:api_key] || ""
        self.location         = data[:location]
        self.zips             = data[:zips] || []
        self.channels         = data[:channels] || []
        self.split_media_type = data[:split_media_type] || []
        self.keywords         = data[:keywords] || []
        self.radius           = data[:radius] || nil
        self.limit            = data[:limit] || "10"
        self.sort             = data[:sort] || Sort.DATE_ASC
        self.page             = data[:page] || "1"
        self.offset           = data[:offset] || "0"
        self.view             = data[:view] || "json"
        self.facet            = data[:facet] || Facet.ACTIVITIES       
        self.num_results      = data[:num_results] || "10"
        self.search           = data[:search] || ""
        self.start_date       = data[:start_date] || "today"
        self.end_date         = data[:end_date] || "+"        
        self.asset_ids        = data[:asset_ids] || []
        self.asset_id         = data[:asset_id] || ""
        self.latitude         = data[:latitude]
        self.longitude        = data[:longitude]
        self.dma              = data[:dma]
        self.city             = data[:city]
        self.state            = data[:state]
        self.country          = data[:country]
        self.bounding_box     = data[:bounding_box]
      end
      
      # Example
      # Search.search( {:zips => "92121, 92078, 92114"} )
      # or
      # Search.new( {:zips => [92121, 92078, 92114]} )
      def zips=(value)
        if value.class == String
          @zips = value.split(",").each { |k| k.strip! }
        else
          @zips = value
        end        
      end
      
      def zips
        @zips
      end
      
      def location=(value)
        return if value.nil?
        @location = CGI.escape(value)
      end
      
      def keywords=(value)
        if value.class == String
          @keywords = value.gsub(",", " ").split(" ").each { |k| k.strip! }
        else
          @keywords = value
        end
      end     
      
      def channels=(value)
        if value.class == String
          @channels = value.split(",").each { |k| k.strip! }
        else
          @channels = value
        end
      end
      
      def asset_ids=(value)
        @asset_ids = value
      end
      
      def bounding_box=(value)
        return if value==nil
        value = HashWithIndifferentAccess.new(value)
        if value.has_key?("sw") && value.has_key?("ne")
          @bounding_box=value
        else
          raise "bounding_box must be hash with keys sw and ne"
        end
      end

      def asset_id=(value)
        return if value.empty?
        @asset_ids<<value
      end
      
      def end_point
        meta_data = ""
        loc_str   = ""
        # CHANNELS
        channel_keys = []
        @channels.each do |c|
          c = c.to_sym
          if Categories.CHANNELS.include?(c)
            channel_keys << Categories.CHANNELS[c]
          else
            puts "///////////  Channel key not found [#{c}]"
          end
        end
        meta_data += channel_keys.collect { |channel| "meta:channel=#{Search.double_encode_channel(channel)}" }.join("+OR+")
        # SPLIT MEDIA TYPE
        if split_media_type
          meta_data += "+AND+" unless meta_data == ""
          meta_data += split_media_type.collect { |type| "meta:splitMediaType=#{Search.double_encode_channel(type)}" }.join("+OR+")           
        end
        # ASSET TYPE ID
        if asset_type_id
          meta_data += "+AND+" unless meta_data == ""
          meta_data += "meta:assetTypeId=#{Search.double_encode_channel(asset_type_id)}" 
        end
        # url
        if url
          meta_data += "+AND+" unless meta_data == ""
          # url.gsub!(/\-/,"%252D")
          url.gsub!(/\//,"%2F")
          # URI.escape(url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          meta_data += "site:#{url}"
          # meta_data += "site:#{Search.double_encode_channel(url)}"
        end
        # ASSET IDS
        unless asset_ids.empty?
          meta_data += "+AND+" unless meta_data == ""
          temp_ids = []
          asset_ids.each do |id|
            temp_ids << "meta:" + CGI.escape("assetId=#{id.gsub("-","%2d")}")
          end        
          meta_data += temp_ids.join("+OR+")          
        end
        # LOCATION
        # 1 Look for :city, :state, :country
        # 2 Look for zip codes
        # 3 Look for lat lng
        # 4 Look for a formatted string "San Diego, CA, US"
        # 5 Look for a dma
        if @city or @state or @country
          if @city
            meta_data += "+AND+" unless meta_data == ""
            meta_data += "meta:city=#{Search.double_encode_channel(@city)}"
          end
          if @state
            meta_data += "+AND+" unless meta_data == ""
            meta_data += "meta:state=#{Search.double_encode_channel(@state)}"         
          end
        elsif !@zips.empty?
          loc_str = @zips.join(",")          
        elsif @latitude and @longitude
          loc_str = "#{@latitude};#{@longitude}"
        elsif @dma
          meta_data += "+AND+" unless meta_data == ""
          meta_data += "meta:dma=#{Search.double_encode_channel(@dma)}"
        else
          loc_str = @location
        end
        
        # BOUNDING BOX
        unless @bounding_box.nil?
          #The values in the GSA metadata are shifted to  prevent negative values.  This was done b/c lat/long
          # are searched as a number range and the GSA doesn't allow negative values in number ranges.  
          # We shift latitude values by 90 and longitude values by 180.
          if @bounding_box[:sw].class==String
            #String :bounding_box => { :sw => "37.695141,-123.013657", :ne => "37.832371,-122.356979"}
            latitude1 = @bounding_box[:sw].split(",").first.to_f+90
            latitude2 = @bounding_box[:ne].split(",").first.to_f+90
            longitude1 = @bounding_box[:sw].split(",").last.to_f+180
            longitude2 = @bounding_box[:ne].split(",").last.to_f+180
          else 
            #hash query[:bounding_box] = { :sw => [123, 10], :ne => [222,10] }
            latitude1 = @bounding_box[:sw].first.to_f+90
            latitude2 = @bounding_box[:ne].first.to_f+90
            longitude1 = @bounding_box[:sw].last.to_f+180
            longitude2 = @bounding_box[:ne].last.to_f+180
          end
          meta_data += "+AND+" unless meta_data == ""
          meta_data += "meta:latitudeShifted:#{latitude1}..#{latitude2}+AND+meta:longitudeShifted:#{longitude1}..#{longitude2}"
        end        
        
        # AND DATE
        if @start_date.class == Date
          @start_date = URI.escape(@start_date.strftime("%m/%d/%Y")).gsub(/\//,"%2F")
        end
        if @end_date.class == Date
          @end_date = URI.escape(@end_date.strftime("%m/%d/%Y")).gsub(/\//,"%2F")
        end
        meta_data += "+AND+" unless meta_data == ""
        meta_data += "meta:startDate:daterange:#{@start_date}..#{@end_date}"
                
        # url = "#{SEARCH_URL}/search?api_key=#{@api_key}&num=#{@num_results}&page=#{@page}&l=#{loc_str}&f=#{@facet}&v=#{@view}&r=#{@radius}&s=#{@sort}&k=#{@keywords.join("+")}&m=#{meta_data}"
        urla = ["#{SEARCH_URL}/search?api_key=#{@api_key}"]
        urla << "num=#{@num_results}" if @num_results
        urla << "page=#{@page}" if @page
        urla << "l=#{loc_str}" unless loc_str.nil? or loc_str.empty?
        urla << "f=#{@facet}" if @facet 
        urla << "v=#{@view}" if @view
        urla << "r=#{@radius}" if @radius
        urla << "s=#{@sort}" if @sort
        urla << "k=#{@keywords.join("+")}" if @keywords and !@keywords.empty? 
        urla << "m=#{meta_data}" if meta_data

        return urla.join("&")
      end
      
      # TODO the seach method should not raise an error.
      def search
        searchurl         = URI.parse(end_point)
        req               = Net::HTTP::Get.new(searchurl.path)
        http              = Net::HTTP.new(searchurl.host, searchurl.port)
        http.read_timeout = DEFAULT_TIMEOUT
        
        puts "Active Search [GET] #{"#{searchurl.path}?#{searchurl.query}"}"
        res = http.start { |http|
          http.get("#{searchurl.path}?#{searchurl.query}")
        }
        
        if (200..307).include?(res.code.to_i)          
          begin
            parsed_json      = JSON.parse(res.body)
            @endIndex        = parsed_json["endIndex"]
            @pageSize        = parsed_json["pageSize"]
            @searchTime      = parsed_json["searchTime"]
            # GSA will only return 1000 events but will give us a number larger then 1000.
            @numberOfResults = (parsed_json["numberOfResults"] <= 1000) ? parsed_json["numberOfResults"] : 1000
            @results         = parsed_json['_results'].collect { |a| Activity.new(GSA.new(a)) }  

            begin
              Active.CACHE.set( Digest::MD5.hexdigest(end_point), self) if Active.CACHE
            rescue Exception => e              
            end

          rescue JSON::ParserError => e
            raise RuntimeError, "JSON::ParserError json=#{res.body}"
            @endIndex        = 0
            @pageSize        = 0
            @searchTime      = 0
            @numberOfResults = 0
            @results         = []             
          end
          
        else
          raise RuntimeError, "Active Search responded with a #{res.code} for your query."
        end
      end
      
      # examples
      #
      #
      # = Keywords = 
      # Keywords can be set like this
      # Search.new({:keywords => "Dog,Cat,Cow"})
      # Search.new({:keywords => %w(Dog Cat Cow)})
      # Search.new({:keywords => ["Dog","Cat","Cow"]})
      #
      # = Channels and MediaType =
      # Search.new({:channels => [:running], :split_media_type => ["5k"]})
      # for a list of channels and splitMediaTypes please see http://developer.active.com/docs/Activecom_Search_API_Reference
      #
      # = Location =
      # The location will be set in this order and will override other values.  For example is you set a zip code and a location only the zip will be used. 
      #
      # 1 Look for zip codes
      #      Search.search( {:zips => "92121, 92078, 92114"} )
      #      Search.search( {:zips => %w(92121, 92078, 92114)} )
      #      Search.search( {:zips => [92121, 92078, 92114]} )
      #
      # 2 Look for lat lng
      #      Search.search( {:latitude=>"37.785895", :longitude=>"-122.40638"} )
      #
      # 3 Look for a formatted string "San Diego, CA, US"
      #       Search.search( {:location = "San Diego, CA, US"} )
      #
      # 4 Look for a DMA
      #       Search.new({:dma=>"San Francisco - Oakland - San Jose"})
      #
      # = How to look at the results =
      #
      #
      # http://developer.active.com/docs/Activecom_Search_API_Reference
      # returns an array of results and query info
      def self.search(data=nil)
        search      = Search.new(data)
        search_hash = Digest::MD5.hexdigest(search.end_point)
        puts "search_hash #{search_hash}"
        cache = Search.return_cached(search_hash)
        if cache != nil
          return cache
        else
          search.search
          return search  
        end
      end

      def self.return_cached key
        if Active.CACHE
          begin
            cached_version = Active.CACHE.get(key)
          rescue Exception => e
            return nil
          end
          
          
          
          if cached_version
            puts "Active Search [CACHE] #{key}"
            return cached_version 
          end
        end
        nil
      end

      
      def []
        @results
      end
      
      private
        def self.double_encode_channel str
          str = URI.escape(str, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          str = URI.escape(str, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          str.gsub!(/\-/,"%252D")
          str
        end
    end
    
    # TODO move to a reflection service
    class Categories
      def self.CHANNELS 
        {
          :active_lifestyle => '',
          :fitness => 'Fitness',
          :body_building => 'Fitness\Body Building',
          :boxing => 'Fitness\Boxing',
          :weight_lifting => 'Fitness\Weight Lifting',
          :gear => 'Gear',
          :lifestyle_vehicles => 'Lifestyle Vehicles',
          :mind_mody => 'Mind & Body',
          :meditation => 'Mind & Body\Meditation',
          :pilates => 'Mind & Body\Pilates',
          :yoga => 'Mind & Body\Yoga',
          :nutrition => 'Nutrition',
          :travel => 'Travel',
          :women => 'Women',
          :other => 'Other',
          :corporate => 'Corporate',
          :not_specified => 'Not Specified',
          :unknown => 'Unknown',
          :special_interest => 'Special+Interest',
          :giving => 'Giving',
          :parks_recreation => 'Parks & Recreation',
          :gear => 'Parks & Recreation\Gear',
          :mind_body => 'Parks & Recreation\Mind & Body',
          :travel => 'Parks & Recreation\Travel',
          :vehicles => 'Parks & Recreation\Vehicles',
          :women => 'Parks & Recreation\Women',
          :reunions => 'Reunions',
          :sports => 'Sports',
          :action_sports => 'Action Sports',
          :auto_racing => 'Action Sports\Auto Racing',
          :bmx => 'Action Sports\BMX',
          :dirt_bike_racing => 'Action Sports\Dirt Bike Racing',
          :motocross => 'Action Sports\Motocross',
          :motorcycle_racing => 'Action Sports\Motorcycle Racing',
          :skateboarding => 'Action Sports\Skateboarding',
          :skydiving => 'Action Sports\Skydiving',
          :surfing => 'Action Sports\Surfing',
          :wake_kite_boarding => 'Action Sports\Wake/Kite Boarding',
          :water_skiing => 'Action Sports\Water Skiing',
          :wind_surfing => 'Action Sports\Wind Surfing',
          :baseball => 'Baseball',
          :little_league_baseball => 'Baseball\Little League Baseball',
          :tee_ball => 'Baseball\Tee Ball',
          :basketball => 'Basketball',
          :cheerleading => 'Cheerleading',
          :cycling => 'Cycling',
          :field_hockey => 'Field Hockey',
          :football => 'Football',
          :flag_football => 'Football\Flag Football',
          :football_au => 'Football\Football-AU',
          :golf => 'Golf',
          :ice_hockey => 'Ice Hockey',
          :lacrosse => 'Lacrosse',
          :more_sports => 'More Sports',
          :adventure_racing => 'More Sports\Adventure Racing',
          :archery => 'More Sports\Archery',
          :badminton => 'More Sports\Badminton',
          :billiards => 'More Sports\Billiards',
          :bowling => 'More Sports\Bowling',
          :cricket => 'More Sports\Cricket',
          :croquet => 'More Sports\Croquet',
          :curling => 'More Sports\Curling',
          :dance => 'More Sports\Dance',
          :disc_sports => 'More Sports\Disc Sports',
          :dodgeball => 'More Sports\Dodgeball',
          :duathlon => 'More Sports\Duathlon',
          :equestrian => 'More Sports\Equestrian',
          :fencing => 'More Sports\Fencing',
          :figure_skating => 'More Sports\Figure Skating',
          :gymnastics => 'More Sports\Gymnastics',
          :inline_hockey => 'More Sports\Inline Hockey',
          :inline_skating => 'More Sports\Inline Skating',
          :kickball => 'More Sports\Kickball',
          :martial_arts => 'More Sports\Martial Arts',
          :paintball => 'More Sports\Paintball',
          :polo => 'More Sports\Polo',
          :racquetball => 'More Sports\Racquetball',
          :rowing => 'More Sports\Rowing',
          :rugby => 'More Sports\Rugby',
          :scouting => 'More Sports\Scouting',
          :scuba_diving => 'More Sports\Scuba Diving',
          :skating => 'More Sports\Skating',
          :squash => 'More Sports\Squash',
          :ultimate_frisbee => 'More Sports\Ultimate Frisbee',
          :water_polo => 'More Sports\Water Polo',
          :mountain_biking => 'Mountain Biking',
          :outdoors => 'Outdoors',
          :canoeing => 'Outdoors\Canoeing',
          :climbing => 'Outdoors\Climbing',
          :hiking => 'Outdoors\Hiking',
          :kayaking => 'Outdoors\Kayaking',
          :orienteering => 'Outdoors\Orienteering',
          :outrigging => 'Outdoors\Outrigging',
          :rafting => 'Outdoors\Rafting',
          :racquetball => 'Racquetball',
          :rugby => 'Rugby',
          :running => 'Running',
          :cross_country => 'Running\Cross Country',
          :marathon_running => 'Running\Marathon Running',
          :track_field => 'Running\Track & Field',
          :trail_running => 'Running\Trail Running',
          :sailing => 'Sailing',
          :snow_sports => 'Snow Sports',
          :skiing => 'Snow Sports\Skiing',
          :snowboarding => 'Snow Sports\Snowboarding',
          :snowshoeing => 'Snow Sports\Snowshoeing',
          :soccer => 'Soccer',
          :softball => 'Softball',
          :softball_dixie => 'Softball\Softball-Dixie',
          :softball_fast_pitch => 'Softball\Softball-Fast Pitch',
          :softball_slow_pitch => 'Softball\Softball-Slow Pitch',
          :squash => 'Squash',
          :swimming => 'Swimming',
          :diving => 'Swimming\Diving',
          :tennis => 'Tennis',
          :other_tennis => 'Tennis\Other Tennis',
          :usta => 'Tennis\USTA',
          :triathlon => 'Triathlon',
          :volleyball => 'Volleyball',
          :walking => 'Walking',
          :wrestling => 'Wrestling'
        }
      end
    end
  
  end
end