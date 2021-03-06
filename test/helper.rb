# this file is automatically required in when you require 'assert' in your tests
# put test helpers here

# add root dir to the load path
$LOAD_PATH.unshift(File.expand_path("../..", __FILE__))
require 'rack/less'

class Assert::Context

  def file_path(*segments)
    segs = segments.unshift([File.dirname(__FILE__), '..']).flatten
    File.expand_path(segs.join(File::SEPARATOR))
  end

  def self.should_compile_source(name, desc)
    setup do
      @compiled = File.read(File.join(@source_folder, "#{name}_compiled.css"))
      @source = Rack::Less::Source.new(name, :folder => @source_folder)
    end

    should "compile LESS" do
      assert_equal @compiled.strip, @source.compiled.strip, '.compiled is incorrect'
      assert_equal @compiled.strip, @source.to_css.strip, '.to_css is incorrect'
      assert_equal @compiled.strip, @source.css.strip, '.css is incorrect'
    end
  end

  def env_defaults
    Rack::Less::Base.defaults.merge({
      Rack::Less::Base.option_name(:root) => file_path('test','fixtures','sinatra')
    })
  end

  def less_request(method, path_info)
    Rack::Less::Request.new(@defaults.merge({
      'REQUEST_METHOD' => method,
      'PATH_INFO' => path_info
    }))
  end

  def less_response(css)
    Rack::Less::Response.new(@defaults, css)
  end

  def self.should_not_be_a_valid_rack_less_request(args)
    desc "to #{args[:method].upcase} #{args[:resource]} (#{args[:description]})"
    setup do
      @request = less_request(args[:method], args[:resource])
    end

    should "not be a valid endpoint for Rack::Less" do
      not_valid = !@request.get?
      not_valid ||= !@request.for_css?
      not_valid ||= @request.source.files.empty?
      assert not_valid, 'request is a GET for .css format and has source'
      assert !@request.for_less?, 'the request is for less'
    end
  end

  def self.should_be_a_valid_rack_less_request(args)
    desc "to #{args[:method].upcase} #{args[:resource]} (#{args[:description]})"
    setup do
      @request = less_request(args[:method], args[:resource])
    end

    should "be a valid endpoint for Rack::Less" do
      assert @request.get?, 'the request is not a GET'
      assert @request.for_css?, 'the request is not for css'
      assert !@request.source.files.empty?, 'the request resource has no source'
      assert @request.for_less?, 'the request is not for less'
    end
  end

end
