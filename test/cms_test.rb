ENV["RACK_ENV"]= "test"

require "minitest/autorun"
require "rack/test"

require_relative "../cms"

class CmsTest < Minitest::Test
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
  
  def test_homepage
    get "/"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "about.txt"
    assert_includes last_response.body, "changes.txt"
    assert_includes last_response.body, "history.txt"
  end
  
  def test_view_text
    get "/changes.txt"
    
    assert_equal 200, last_response.status
    assert_equal "plain text", last_response["Content-Type"]
    assert_includes last_response.body, "Ch-ch-ch-ch-changes"
  end
  
  def test_route_to_invalid_file 
    get "/potatofarmer45232"

    assert_equal 302, last_response.status 
    
    get last_response["Location"] # Request the page that the user was redirected to

    assert_equal 200, last_response.status
    assert_includes last_response.body, "potatofarmer45232 does not exist"

    get "/" # Reload the page
    refute_includes last_response.body, "notafile.ext does not exist"
  end
end