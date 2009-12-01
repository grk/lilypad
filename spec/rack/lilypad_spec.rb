require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Rack::Lilypad do

  include Rack::Test::Methods

  def app
    SinatraApp.new
  end
  
  before(:each) do
    ENV['RACK_ENV'] = 'production'
    @http = mock(:http)
    @http.stub!(:read_timeout=)
    @http.stub!(:open_timeout=)
    @http.stub!(:post)
    Net::HTTP.stub!(:start).and_yield(@http)
  end
  
  it "yields a configuration object to the block when created" do
    notifier = Rack::Lilypad.new(lambda {}, '') do |app|
      app.filters << %w(T1 T2)
    end
    notifier.filters.should include('T1')
    notifier.filters.should include('T2')
  end
  
  it "should post an error to Hoptoad" do
    @http.should_receive(:post)
    get "/raise" rescue nil
  end
  
  it "should re-raise the exception" do
    lambda { get "/raise" }.should raise_error(TestError)
  end
  
  it "should transfer valid XML to Hoptoad" do
    get "/raise" rescue nil
    
    xsd = Nokogiri::XML::Schema(File.read(SPEC + '/fixtures/hoptoad_2_0.xsd'))
    doc = Nokogiri::XML(Rack::Lilypad::Hoptoad.last_response)
    
    errors = xsd.validate(doc)
    errors.each do |error|
      puts error.message
    end
    errors.length.should == 0
  end
end