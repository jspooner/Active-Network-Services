module Active
  module Services
    class Validators
      
      def self.email arg
        if (arg =~  /((\w|-)+(\.\w+)?)+@\w+\.\w+/) == nil  
        # if (arg =~  /^(\w|\.|-)+?@(\w|-)+?\.\w{2,4}($|\.\w{2,4})$/) == nil
          return false
        else
          return true
        end
      end
      
      # return true or false
      # very short check for 5 consecutive digits, no leading or trailing whitespace.
      def self.zip(arg)
        # if (arg =~ /\be(\w*)/) != -1
        #   true
        # else
        #   false
        # end
      end
      
      def self.state
        true
      end
      
      def self.city
        false
      end
      
      def self.address
        false
      end
      
      STATES = [
        [ "Alabama", "AL" ],
        [ "Alaska", "AK" ],
        [ "Arizona", "AZ" ],
        [ "Arkansas", "AR" ],
        [ "California", "CA" ],
        [ "Colorado", "CO" ],
        [ "Connecticut", "CT" ],
        [ "Delaware", "DE" ],
        [ "District Of Columbia", "DC" ],
        [ "Florida", "FL" ],
        [ "Georgia", "GA" ],
        [ "Hawaii", "HI" ],
        [ "Idaho", "ID" ],
        [ "Illinois", "IL" ],
        [ "Indiana", "IN" ],
        [ "Iowa", "IA" ],
        [ "Kansas", "KS" ],
        [ "Kentucky", "KY" ],
        [ "Louisiana", "LA" ],
        [ "Maine", "ME" ],
        [ "Maryland", "MD" ],
        [ "Massachusetts", "MA" ],
        [ "Michigan", "MI" ],
        [ "Minnesota", "MN" ],
        [ "Mississippi", "MS" ],
        [ "Missouri", "MO" ],
        [ "Montana", "MT" ],
        [ "Nebraska", "NE" ],
        [ "Nevada", "NV" ],
        [ "New Hampshire", "NH" ],
        [ "New Jersey", "NJ" ],
        [ "New Mexico", "NM" ],
        [ "New York", "NY" ],
        [ "North Carolina", "NC" ],
        [ "North Dakota", "ND" ],
        [ "Ohio", "OH" ],
        [ "Oklahoma", "OK" ],
        [ "Oregon", "OR" ],
        [ "Pennsylvania", "PA" ],
        [ "Rhode Island", "RI" ],
        [ "South Carolina", "SC" ],
        [ "South Dakota", "SD" ],
        [ "Tennessee", "TN" ],
        [ "Texas", "TX" ],
        [ "Utah", "UT" ],
        [ "Vermont", "VT" ],
        [ "Virginia", "VA" ],
        [ "Washington", "WA" ],
        [ "West Virginia", "WV" ],
        [ "Wisconsin", "WI" ],
        [ "Wyoming", "WY" ]
      ]

      def self.full_name(abbr)
        STATES.find do |i|
          if i[1] == abbr.upcase
            return i[0]
          end
        end
        return nil
      end

      def self.valid_state(name)
        return nil if name.nil?
        STATES.find do |i|
          if i[0].upcase==name.strip.upcase
            return i[0]
          elsif i[1] == name.upcase
            return i[0]
          end
        end
        return nil
      end

      # NO MODIFYING IN A VALIDATION CLASS 
      # !! clean zip 
      # (http://geekswithblogs.net/MainaD/archive/2007/12/03/117321.aspx)
      def self.valid_zip(zip)
        if zip!="00000" && zip.to_s.strip=~/(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1} *\d{1}[A-Z]{1}\d{1}$)/
          return zip.to_s.strip
        else
          return nil
        end
      end
    end
    
  end
end