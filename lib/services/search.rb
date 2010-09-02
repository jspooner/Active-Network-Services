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
        :corporate                                               => "corporate",
        :nochannel                                               => "nochannel",
        :action_sports                                           => "action_sports",
        :auto_racing                                             => "auto_racing",
        :baseball                                                => "baseball",
        :little_league_baseball                                  => "baseball\\little_league_baseball",
        :tee_ball                                                => "baseball\\tee_ball",
        :littleleague                                            => "baseball\\littleleague",
        :basketball                                              => "basketball",
        :bmx                                                     => "bmx",
        :cheerleading                                            => "cheerleading",
        :cycling                                                 => "cycling",
        :tourofca                                                => "cycling\\tourofca",
        :gift_guide                                              => "cycling\\gift_guide",
        :dirt_bike_racing                                        => "dirt_bike_racing",
        :field_hockey                                            => "field_hockey",
        :football                                                => "football",
        :flag_football                                           => "football\\flag_football",
        :football_au                                             => "football\\football_au",
        :pop_warner                                              => "football\\pop_warner",
        :golf                                                    => "golf",
        :ice_hockey                                              => "ice_hockey",
        :lacrosse                                                => "lacrosse",
        :motocross                                               => "motocross",
        :motorcycle_racing                                       => "motorcycle_racing",
        :mountain_biking                                         => "mountain_biking",
        :outdoors                                                => "outdoors",
        :canoeing                                                => "outdoors\\canoeing",
        :climbing                                                => "outdoors\\climbing",
        :hiking                                                  => "outdoors\\hiking",
        :kayaking                                                => "outdoors\\kayaking",
        :orienteering                                            => "outdoors\\orienteering",
        :outrigging                                              => "outdoors\\outrigging",
        :rafting                                                 => "outdoors\\rafting",
        :gift_guide                                              => "outdoors\\gift_guide",
        :running                                                 => "running",
        :cross_country                                           => "running\\cross_country",
        :track_and_field                                         => "running\\track_and_field",
        :trail_running                                           => "running\\trail_running",
        :gift_guide                                              => "running\\gift_guide",
        :jinglebell                                              => "running\\jinglebell",
        :spiritofthemarathon                                     => "running\\spiritofthemarathon",
        :stpatricksday                                           => "running\\stpatricksday",
        :marathonmania                                           => "running\\marathonmania",
        :newbierunners                                           => "running\\newbierunners",
        :sailing                                                 => "sailing",
        :skateboarding                                           => "skateboarding",
        :skiing                                                  => "skiing",
        :skydiving                                               => "skydiving",
        :snowboarding                                            => "snowboarding",
        :snowshoeing                                             => "snowshoeing",
        :soccer                                                  => "soccer",
        :softball                                                => "softball",
        :dixie                                                   => "softball\\dixie",
        :fastpitch                                               => "softball\\fastpitch",
        :slowpitch                                               => "softball\\slowpitch",
        :little_league                                           => "softball\\little_league",
        :surfing                                                 => "surfing",
        :swimming                                                => "swimming",
        :diving                                                  => "swimming\\diving",
        :open_water_swimming                                     => "swimming\\open_water_swimming",
        :masters                                                 => "swimming\\masters",
        :tennis                                                  => "tennis",
        :usta                                                    => "tennis\\usta",
        :college                                                 => "tennis\\college",
        :triathlon                                               => "triathlon",
        :ironblog                                                => "triathlon\\ironblog",
        :gift_guide                                              => "triathlon\\gift_guide",
        :volleyball                                              => "volleyball",
        :walking                                                 => "walking",
        :wake_kite_boarding                                      => "wake%2Fkite_boarding",
        :water_skiing                                            => "water_skiing",
        :wind_surfing                                            => "wind_surfing",
        :water_sports                                            => "water_sports",
        :more_sports                                             => "more_sports",
        :adventure_racing                                        => "more_sports\\adventure_racing",
        :archery                                                 => "more_sports\\archery",
        :badminton                                               => "more_sports\\badminton",
        :billiards                                               => "more_sports\\billiards",
        :bowling                                                 => "more_sports\\bowling",
        :cricket                                                 => "more_sports\\cricket",
        :croquet                                                 => "more_sports\\croquet",
        :curling                                                 => "more_sports\\curling",
        :dance                                                   => "more_sports\\dance",
        :disc_sports                                             => "more_sports\\disc_sports",
        :dodgeball                                               => "more_sports\\dodgeball",
        :duathlon                                                => "more_sports\\duathlon",
        :equestrian                                              => "more_sports\\equestrian",
        :fencing                                                 => "more_sports\\fencing",
        :figure_skating                                          => "more_sports\\figure_skating",
        :fishing                                                 => "more_sports\\fishing",
        :gymnastics                                              => "more_sports\\gymnastics",
        :inline_hockey                                           => "more_sports\\inline_hockey",
        :kickball                                                => "more_sports\\kickball",
        :martial_arts                                            => "more_sports\\martial_arts",
        :paintball                                               => "more_sports\\paintball",
        :polo                                                    => "more_sports\\polo",
        :racquetball                                             => "more_sports\\racquetball",
        :rowing                                                  => "more_sports\\rowing",
        :rugby                                                   => "more_sports\\rugby",
        :scuba_diving                                            => "more_sports\\scuba_diving",
        :skating                                                 => "more_sports\\skating",
        :squash                                                  => "more_sports\\squash",
        :ultimate_frisbee                                        => "more_sports\\ultimate_frisbee",
        :water_polo                                              => "more_sports\\water_polo",
        :wrestling                                               => "wrestling",
        :nutrition                                               => "nutrition",
        :fitness                                                 => "fitness",
        :body_building                                           => "fitness\\body_building",
        :boxing                                                  => "fitness\\boxing",
        :weight_lifting                                          => "fitness\\weight_lifting",
        :wellness                                                => "fitness\\wellness",
        :gymnastics_centers                                      => "fitness\\gymnastics_centers",
        :martial_arts_centers                                    => "fitness\\martial_arts_centers",
        :massage                                                 => "fitness\\massage",
        :chiropractors                                           => "fitness\\chiropractors",
        :therapy                                                 => "fitness\\therapy",
        :travel                                                  => "travel",
        :marinas                                                 => "travel\\marinas",
        :campgrounds_and_rv_parks                                => "travel\\campgrounds_and_rv_parks",
        :state_muni_hunting_and_fishing_licensing                => "travel\\state_muni_hunting_and_fishing_licensing",
        :boat_licensing_departments                              => "travel\\boat_licensing_departments",
        :lodges_bandbs_country_inns_hostels                      => "travel\\lodges_bandbs_country_inns_hostels",
        :hotels_resorts_motels                                   => "travel\\hotels_resorts_motels",
        :condo_rental_time_share                                 => "travel\\condo_rental_time_share",
        :charters_tours                                          => "travel\\charters_tours",
        :cruises                                                 => "travel\\cruises",
        :gear                                                    => "gear",
        :sony_gps                                                => "gear\\sony_gps",
        :mind_and_body                                           => "mind_and_body",
        :meditation                                              => "mind_and_body\\meditation",
        :pilates                                                 => "mind_and_body\\pilates",
        :yoga                                                    => "mind_and_body\\yoga",
        :women                                                   => "women",
        :gift_guide                                              => "women\\gift_guide",
        :fit_pregnancy                                           => "women\\fit_pregnancy",
        :lifestyle_vehicles                                      => "lifestyle_vehicles",
        :community_services                                      => "community_services",
        :parks_and_recs                                          => "community_services\\parks_and_recs",
        :private_gated_community_rec                             => "community_services\\private_gated_community_rec",
        :summer_and_day_camps                                    => "community_services\\summer_and_day_camps",
        :military_recreation                                     => "community_services\\military_recreation",
        :libraries                                               => "community_services\\libraries",
        :business_training_professional_and_personal_development => "community_services\\business_training_professional_and_personal_development",
        :art_music_voice_dance_acting                            => "community_services\\art_music_voice_dance_acting",
        :flea_markets_swap_meets                                 => "community_services\\flea_markets_swap_meets",
        :non_profit_services                                     => "non_profit_services",
        :ymca_jcc_boys_and_girls_clubs                           => "non_profit_services\\ymca_jcc_boys_and_girls_clubs",
        :boy_scouts_girls_scouts                                 => "non_profit_services\\boy_scouts_girls_scouts",
        :religious                                               => "non_profit_services\\religious",
        :giving_and_fundraising                                  => "giving_and_fundraising",
        :health_and_disease                                      => "giving_and_fundraising\\health_and_disease",
        :political                                               => "giving_and_fundraising\\political",
        :environment                                             => "giving_and_fundraising\\environment",
        :faith                                                   => "giving_and_fundraising\\faith",
        :animals                                                 => "giving_and_fundraising\\animals",
        :educational_support                                     => "giving_and_fundraising\\educational_support",
        :international                                           => "giving_and_fundraising\\international",
        :other                                                   => "giving_and_fundraising\\other",
        :attractions                                             => "attractions",
        :aquatic_parks                                           => "attractions\\aquatic_parks",
        :amusement_parks                                         => "attractions\\amusement_parks",
        :zoos                                                    => "attractions\\zoos",
        :aquariums                                               => "attractions\\aquariums",
        :science_and_nature_centers                              => "attractions\\science_and_nature_centers",
        :museums                                                 => "attractions\\museums",
        :general_admission_concerts_and_events                   => "attractions\\general_admission_concerts_and_events",
        :ski_resorts                                             => "attractions\\ski_resorts",
        :carnivals                                               => "attractions\\carnivals",
        :miniature_golf                                          => "attractions\\miniature_golf",
        :education                                               => "education",
        :universities                                            => "education\\universities",
        :community_junior_colleges                               => "education\\community_junior_colleges",
        :public_school_boards                                    => "education\\public_school_boards",
        :continuing_education_departments                        => "education\\continuing_education_departments",
        :high_schools                                            => "education\\high_schools",
        :private_schools                                         => "education\\private_schools",
        :pre_schools                                             => "education\\pre_schools",
        :youth_academic_extracurricular                          => "education\\youth_academic_extracurricular",
        :government                                              => "government",
        :city_hall                                               => "government\\city_hall",
        :parking                                                 => "government\\parking",
        :animal_licensing                                        => "government\\animal_licensing",
        :municipal_business_licensing                            => "government\\municipal_business_licensing",
        :traffic_ticketing                                       => "government\\traffic_ticketing",
        :utility_billing                                         => "government\\utility_billing",
        :building_permits                                        => "government\\building_permits",
        :taxes                                                   => "government\\taxes",
        :state_dmvs                                              => "government\\state_dmvs",
        :federal_government                                      => "government\\federal_government",
        :business_and_commerce                                   => "business_and_commerce",
        :corporations                                            => "business_and_commerce\\corporations",
        :conferences_and_conventions                             => "business_and_commerce\\conferences_and_conventions",
        :affinity_groups                                         => "business_and_commerce\\affinity_groups",
        :counseling_therapy                                      => "business_and_commerce\\counseling_therapy",
        :pet_care                                                => "business_and_commerce\\pet_care",
        :beauty_and_personal_care                                => "business_and_commerce\\beauty_and_personal_care",
        :restaurants                                             => "business_and_commerce\\restaurants",
        :high_school                                             => "high_school",
        :hs_activities                                           => "high_school\\hs_activities",
        :hs_varsity_sports_club_sports                           => "high_school\\hs_varsity_sports_club_sports",
        :continuing_education                                    => "high_school\\continuing_education",
        :scouts                                                  => "scouts",
        :bsa                                                     => "scouts\\bsa",
        :gsus4h                                                  => "scouts\\gsus4h",
        :'4h'                                                    => "scouts\\4h",
        :campfire                                                => "scouts\\campfire",
        :sea_scouts                                              => "scouts\\sea_scouts",
        :fccla                                                   => "scouts\\fccla",
        :reunions                                                => "reunions",
        :teams                                                   => "teams",
        :gift_guide                                              => "teams\\gift_guide",
        :golf_tennis                                             => "golf_tennis",
        :gift_guide                                              => "golf_tennis\\gift_guide"
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
          :api_key => "",
          :view => "json",
          :facet => Facet.ACTIVITIES,
          :sort => Sort.DATE_ASC,
          :radius => "10",
          :meta => "",
          :num_results => "10",
          :page => "1",
          :location => "",
          :search => "",
          :keywords => [],
          :channels => nil,
          :start_date => "today",
          :end_date => "+"
        }
        options.merge!(arg_options)
        
        options[:location] = CGI.escape(options[:location]) if options[:location]
        
        if options[:keywords].class == String
          options[:keywords] = options[:keywords].split(",")
          options[:keywords].each { |k| k.strip! }
        end
        
        if options[:channels] != nil          
          channels_a = options[:channels].collect { |channel|
            "meta:channel=#{URI.escape(URI.escape(channel, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")),Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")).gsub(/\-/,"%252D")}"            
          }
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

        # 
        # if @asset_type_id!=nil
        #   @meta = @meta + "+AND+" if @meta!=""
        #   @meta = @meta + "inmeta:assetTypeId=#{@asset_type_id}" 
        # end
        # 
        url = "#{SEARCH_URL}/search?api_key=#{options[:api_key]}&num=#{options[:num_results]}&page=#{options[:page]}&l=#{options[:location]}&f=#{options[:facet]}&v=#{options[:view]}&r=#{options[:radius]}&s=#{options[:sort]}&k=#{options[:keywords].join("+")}&m=#{meta_data}"
        puts url
        url
      end
      
  
      
    end
  end
end