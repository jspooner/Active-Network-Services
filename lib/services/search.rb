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
      # attr_accessor :location, :category, :channels, :daterange, :keywords, :radius, :limit, :sort, :page, :offset,
      #               :asset_type_id, :api_key, :num_results, :view, :facet, :sort
      # 
      SEARCH_URL      = "http://search.active.com"
      DEFAULT_TIMEOUT = 5

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


      # http://developer.active.com/docs/Activecom_Search_API_Reference
      # 
      def self.search(data=nil)
        searchurl         = URI.parse(construct_url(data))
        req               = Net::HTTP::Get.new(searchurl.path)
        http              = Net::HTTP.new(searchurl.host, searchurl.port)
        http.read_timeout = DEFAULT_TIMEOUT

        res = http.start { |http|
          http.get("#{searchurl.path}?#{searchurl.query}")
        }
        
        if res.code == '200'
          parsed_json = JSON.parse(res.body)
          parsed_json['_results'].collect { |a| Activity.new(a) }          
        else
          raise RuntimeError, "Active Search responded with a #{res.code} for your query."
        end
      end
      
      def self.construct_url(arg_options={})
        options = {
          :api_key     => "",
          :view        => "json",
          :facet       => Facet.ACTIVITIES,
          :sort        => Sort.DATE_ASC,
          :radius      => "10",
          :meta        => "",
          :num_results => "10",
          :page        => "1",
          :location    => "",
          :search      => "",
          :keywords    => [],
          :channels    => nil,
          :start_date  => "today",
          :end_date    => "+"
        }
        options.merge!(arg_options)

        return arg_options[:url] if arg_options.keys.index(:url) #a search url was specified - bypass parsing the options (trending)
        
        options[:location] = CGI.escape(options[:location]) if options[:location]
        
        if options[:keywords].class == String
          options[:keywords] = options[:keywords].split(",")
          options[:keywords].each { |k| k.strip! }
        end
        if options[:channels] != nil     
          
          channel_keys = []
          options[:channels].each do |c|
            c.to_sym
            if self.CHANNELS.include?(c)
              channel_keys << self.CHANNELS[c]
            end
          end
          
          channels_a = channel_keys.collect { |channel| "meta:channel=#{Search.double_encode_channel(channel)}" }
        end

        meta_data  = ""
        meta_data  = channels_a.join("+OR+") if channels_a

        meta_data += "+AND+" unless meta_data == ""
        if options[:start_date].class == Date
          options[:start_date] = URI.escape(options[:start_date].strftime("%m/%d/%Y")).gsub(/\//,"%2F")
        end

        if options[:end_date].class == Date
          options[:end_date] = URI.escape(options[:end_date].strftime("%m/%d/%Y")).gsub(/\//,"%2F")
        end
        meta_data += "meta:startDate:daterange:#{options[:start_date]}..#{options[:end_date]}"

        # if @asset_type_id!=nil
        #   @meta = @meta + "+AND+" if @meta!=""
        #   @meta = @meta + "inmeta:assetTypeId=#{@asset_type_id}" 
        # end
        # 
        url = "#{SEARCH_URL}/search?api_key=#{options[:api_key]}&num=#{options[:num_results]}&page=#{options[:page]}&l=#{options[:location]}&f=#{options[:facet]}&v=#{options[:view]}&r=#{options[:radius]}&s=#{options[:sort]}&k=#{options[:keywords].join("+")}&m=#{meta_data}"
        puts "//////"
        puts url
        puts "//////"
        url
      end
      
      private
        def self.double_encode_channel str
          str = URI.escape(str, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          str = URI.escape(str, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          str.gsub!(/\-/,"%252D")
          str
        end
      
    end
  end
end