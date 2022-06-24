require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "rack"
require "redcarpet"

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
markdown.render("")

configure do
  enable :sessions
  set :session_secret, 'secret'
end

# def valid_file?(filename)
#   root = File.expand_path("..", __FILE__)
  
#   Dir.glob(root + "/data/*").any? do |file|
#     File.basename(file) == filename
#   end
# end

root = File.expand_path("..", __FILE__)


# Homepage
get '/' do
  @filenames = Dir.glob(root + "/data/*").map do |file|
    File.basename(file)
  end

  erb :homepage
end

# File page
get "/:filename" do
  filename = params[:filename]
  filepath = root + "/data/" + filename

  if File.file?(filepath)
    headers "Content-Type" => "plain text"
    File.open(filepath)
  else
    session[:error] = "$#{filename} does not exist."
    redirect "/"
  end
  # erb :file
end

not_found do
  redirect "/"
end