module Rack::Less
  
  # Handles configuration for Rack::Less
  # Available config settings:
  # :cache
  #   whether to cache the compilation output to
  #   a corresponding static file. Also determines
  #   what value config#combinations(:key) returns
  # :compress
  #   whether to remove extraneous whitespace from
  #   compilation output
  # :combinations
  #   Rack::Less uses combinations as directives for
  #   combining the output of many stylesheets and
  #   serving them as a single resource.  Combinations
  #   are defined using a hash, where the key is the
  #   resource name and the value is an array of
  #   names specifying the stylesheets to combine
  #   as that resource.  For example:
  #     Rack::Less.config.combinations = {
  #       'web'    => ['reset', 'common', 'app_web'],
  #       'mobile' => ['reset', 'iui', 'common', 'app_mobile']
  #     }
  # :combination_timestamps
  #   whether to append a timestamp to the sheet requests generated by combinations
  class Config
    
    ATTRIBUTES = [:cache, :compress, :combinations, :combination_timestamp]
    attr_accessor *ATTRIBUTES
    
    DEFAULTS = {
      :cache        => false,
      :compress     => false,
      :combinations => {},
      :combination_timestamp => false
    }

    def initialize(settings={})
      ATTRIBUTES.each do |a|
        instance_variable_set("@#{a}", settings[a] || DEFAULTS[a])
      end
    end
    
    def cache?
      !!@cache
    end
    
    def compress?
      !!@compress
    end
    
    def combinations(key=nil)
      if key.nil?
        @combinations
      else
        if cache?
          combo_filename(key)
        else
          (@combinations[key] || []).collect do |combo|
            combo_filename(combo)
          end
        end
      end
    end
    
    private
    
    def combo_filename(combo)
      filename = combo.strip
      filename += ".css" unless filename.include?('.css')
      if !filename.include?('?') && combination_timestamp
        filename += "?"
        filename += if combination_timestamp == true
          Time.now.to_i
        else
          combination_timestamp
        end.to_s
      end
      filename
    end
    
  end
end