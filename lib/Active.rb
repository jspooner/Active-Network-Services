require 'active/version'

module Active
  # require files in order!
  [:errors, :finder_methods, :query_methods, :query, :asset].each do |constant|
    require "active/#{constant.to_s}"
  end
    
end
