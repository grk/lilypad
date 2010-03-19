class SinatraApp < Sinatra::Base
  set :environment, :production

  use Rack::Lilypad, '' do
    sinatra
  end
  use TestExceptionMiddleware
  
  get "/nothing" do
    nil
  end
  
  get "/test" do
    raise TestError, 'Test'
  end
end
