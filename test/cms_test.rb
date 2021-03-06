ENV["RACK_ENV"]= "test"

require "fileutils"

require "minitest/autorun"
require "rack/test"

require_relative "../cms"

class CmsTest < Minitest::Test
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
  
  def setup
    FileUtils.mkdir_p(data_path)
  end
  
  def teardown
    FileUtils.rm_rf(data_path)
  end
  
  def create_document(name, content = "")
    File.open(File.join(data_path, name), "w") do |file|
      file.write(content)
    end
  end
  
  def test_homepage
    create_document("about.md")
    create_document("changes.txt")
    create_document("history.txt")
    
    get "/"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "about.md"
    assert_includes last_response.body, "changes.txt"
    assert_includes last_response.body, "history.txt"
  end
  
  def test_view_text
    create_document("changes.txt", "Ch-ch-ch-ch-changes")
    
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
    refute_includes last_response.body, "potatofarmer45232 does not exist"
  end
  
  def test_rendering_md
    create_document("about.md", "<h1>Hello fans of Matz and Bowie</h1>")
    
    get "/about.md"
    
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>Hello fans of Matz and Bowie</h1>"
  end
  
  def test_editing_file
    create_document("new_file.txt", "<textarea %q(<button type=")
    
    get "/new_file.txt/edit?"

    assert_equal 200, last_response.status 
    assert_includes last_response.body, "<textarea"
    assert_includes last_response.body, %q(<button type="submit")
  end
  
  def test_updating_file
    post "/new_file.txt", content: "new content"
    assert_equal 302, last_response.status 
    
    get last_response["Location"]
    assert_includes last_response.body, "new_file.txt has been updated"
    
    get "/new_file.txt"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "new content"
  end
end