require 'active/version'

module Active
  # require files in order!
  [:finder_methods, :query_methods, :data, :errors, :query, :asset].each do |constant|
    require "active/#{constant.to_s}"
  end
end
