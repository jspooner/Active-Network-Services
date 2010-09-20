require 'net/http'
require 'json'
require 'cgi'
require 'rubygems'
require 'mysql' 
require 'active_record'

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
      attr_accessor :api_key, :start_date, :end_date, :location, :channels, :keywords, :search, :radius, :limit, :sort, :page, :offset,
                    :view, :facet, :sort, :num_results, :asset_ids
                    
      attr_reader :results, :endIndex, :pageSize, :searchTime, :numberOfResults, :end_point, :meta
       
      SEARCH_URL      = "http://search.active.com"
      DEFAULT_TIMEOUT = 60
      
      def initialize(data={})
        self.api_key     = data[:api_key] || ""
        self.location    = data[:location] || ""
        self.zips        = data[:zips] || []
        self.channels    = data[:channels] || []
        self.keywords    = data[:keywords] || []
        self.radius      = data[:radius] || "50"
        self.limit       = data[:limit] || "10"
        self.sort        = data[:sort] || Sort.DATE_ASC
        self.page        = data[:page] || "1"
        self.offset      = data[:offset] || "0"
        self.view        = data[:view] || "json"
        self.facet       = data[:facet] || Facet.ACTIVITIES       
        self.num_results = data[:num_results] || "10"
        self.search      = data[:search] || ""
        self.start_date  = data[:start_date] || "today"
        self.end_date    = data[:end_date] || "+"        
        self.asset_ids   = data[:asset_ids] || []
        self.asset_id    = data[:asset_id] || ""
        
      end
      
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
        @location = CGI.escape(value)
      end
      
      def keywords=(value)
        if value.class == String
          @keywords = value.split(",").each { |k| k.strip! }
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

      def asset_id=(value)
        return if value.empty?
        @asset_ids<<value
      end
      
      def end_point
        meta_data  = ""
        # CHANNELS
        channel_keys = []
        @channels.each do |c|
          c.to_sym
          if Categories.CHANNELS.include?(c)
            channel_keys << Categories.CHANNELS[c]
          end
        end
        meta_data = channel_keys.collect { |channel| "meta:channel=#{Search.double_encode_channel(channel)}" }.join("+OR+")
        puts meta_data
        # ASSET IDS
        
        
        unless asset_ids.empty?
          meta_data += "+AND+" unless meta_data == ""
          temp_ids = []
          asset_ids.each do |id|
            temp_ids << "meta:" + CGI.escape("assetId=#{id.gsub("-","%2d")}")
          end        
          meta_data += temp_ids.join("+OR+")          
        end
        
        
        # trending_asset_order=[]
        # trending.each do |asset_id|
        #   trending_asset_order << asset_id[0]
        #   @m = @m + "+OR+" if @m!=""
        # 
        #   str = "assetId=#{asset_id[0].gsub("-","%2d")}"
        #   str = CGI.escape(str)
        #   @m = @m + "meta:#{str}"
        # end
        
        if @zips.empty?
          loc_str = @location
        else
          loc_str = @zips.join(",")          
        end
        
        
# meta_data  = self.channels.join("+OR+")
        # AND DATE
        meta_data += "+AND+" unless meta_data == ""
        if @start_date.class == Date
          @start_date = URI.escape(@start_date.strftime("%m/%d/%Y")).gsub(/\//,"%2F")
        end
        if @end_date.class == Date
          @end_date = URI.escape(@end_date.strftime("%m/%d/%Y")).gsub(/\//,"%2F")
        end
        meta_data += "meta:startDate:daterange:#{@start_date}..#{@end_date}"
        
        url = "#{SEARCH_URL}/search?api_key=#{@api_key}&num=#{@num_results}&page=#{@page}&l=#{loc_str}&f=#{@facet}&v=#{@view}&r=#{@radius}&s=#{@sort}&k=#{@keywords.join("+")}&m=#{meta_data}"
      end
      
      def search
        searchurl         = URI.parse(end_point)
        req               = Net::HTTP::Get.new(searchurl.path)
        http              = Net::HTTP.new(searchurl.host, searchurl.port)
        http.read_timeout = DEFAULT_TIMEOUT
        
        puts "#{searchurl.path}?#{searchurl.query}"
        
        res = http.start { |http|
          http.get("#{searchurl.path}?#{searchurl.query}")
        }
        
        if (200..307).include?(res.code.to_i)
          parsed_json      = JSON.parse(res.body)
          @endIndex        = parsed_json["endIndex"]
          @pageSize        = parsed_json["pageSize"]
          @searchTime      = parsed_json["searchTime"]
          @numberOfResults = parsed_json["numberOfResults"]
          @results         = parsed_json['_results'].collect { |a| Activity.new(a) }
        else
          raise RuntimeError, "Active Search responded with a #{res.code} for your query."
        end
      end
      
      # examples
      #
      # Search.new({:location => "San Diego"})
      #
      # Keywords can be set like this
      # Search.new({:keywords => "Dog,Cat,Cow"})
      # Search.new({:keywords => %w(Dog Cat Cow)})
      # Search.new({:keywords => ["Dog","Cat","Cow"]})
      #
      # http://developer.active.com/docs/Activecom_Search_API_Reference
      # returns an array of results and query info
      def self.search(data=nil)
        search = Search.new(data)
        search.search
        return search
      end
      
      # def self.construct_url(arg_options={})
      #   return arg_options[:url] if arg_options.keys.index(:url) #todo use has_key? #a search url was specified - bypass parsing the options (trending)
      #   # self.merge!(arg_options)
      # 
      #   # options[:location] = CGI.escape(options[:location]) if options[:location]
      #   
      #   # if options[:keywords].class == String
      #   #           options[:keywords] = options[:keywords].split(",")
      #   #           options[:keywords].each { |k| k.strip! }
      #   #         end
      # 
      #   # if options[:channels] != nil     
      #   #   channel_keys = []
      #   #   options[:channels].each do |c|
      #   #     c.to_sym
      #   #     if self.CHANNELS.include?(c)
      #   #       channel_keys << self.CHANNELS[c]
      #   #     end
      #   #   end
      #   #   channels_a = channel_keys.collect { |channel| "meta:channel=#{Search.double_encode_channel(channel)}" }
      #   # end
      # 
      #   meta_data  = ""
      #   meta_data  = channels_a.join("+OR+") if channels_a
      # 
      #   meta_data += "+AND+" unless meta_data == ""
      #   if options[:start_date].class == Date
      #     options[:start_date] = URI.escape(options[:start_date].strftime("%m/%d/%Y")).gsub(/\//,"%2F")
      #   end
      # 
      #   if options[:end_date].class == Date
      #     options[:end_date] = URI.escape(options[:end_date].strftime("%m/%d/%Y")).gsub(/\//,"%2F")
      #   end
      #   meta_data += "meta:startDate:daterange:#{options[:start_date]}..#{options[:end_date]}"
      # 
      #   url = "#{SEARCH_URL}/search?api_key=#{options[:api_key]}&num=#{options[:num_results]}&page=#{options[:page]}&l=#{options[:location]}&f=#{options[:facet]}&v=#{options[:view]}&r=#{options[:radius]}&s=#{options[:sort]}&k=#{options[:keywords].join("+")}&m=#{meta_data}"
      #   puts url
      #   url
      #   self.end_point = url
      # end
      
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