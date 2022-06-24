require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "rack"
require "redcarpet"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

def load_file_content(filepath)
  text = File.read(filepath)
  
  if File.fnmatch?("*md", filepath)
    render_markdown(text)
  else 
    headers "Content-Type" => "plain text"
    text
  end
end


# def valid_file?(filename)
#   root = File.expand_path("..", __FILE__)
  
#   Dir.glob(root + "/data/*").any? do |file|
#     File.basename(file) == filename
#   end
# end

# root = File.expand_path("..", __FILE__)


# Homepage
get '/' do
  filepath = File.join(data_path, "*")
  p filepath
  @filenames = Dir.glob(filepath).map do |file|
    File.basename(file)
  end

  erb :homepage
end

# Display contents of file
get "/:filename" do
  filename = params[:filename]
  filepath = File.join(data_path, filename)

  if File.file?(filepath)
    load_file_content(filepath)
  else
    session[:notification] = "$#{filename} does not exist."
    redirect "/"
  end
  # erb :file
end

# Edit file
get "/:filename/edit?" do
  filename = params[:filename]
  filepath = File.join(data_path, filename)
  @content = File.read(filepath)
  
  erb :edit_file
end

# Update file
post "/:filename" do
  filename = params[:filename]
  filepath = File.join(data_path, filename)
  File.write(filepath, params[:content])
  
  session[:notification] = "#{filename} has been updated."
  redirect "/"
end

not_found do
  redirect "/"
end