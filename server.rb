require 'rubygems'
require 'sinatra'

class DisableCache
   def initialize(app)
      @app = app
   end

   def call(env)
      result = @app.call(env)
      result[1]['Cache-Control'] = 'no-cache, no-store, must-revalidate'
      result[1]['Pragma'] = 'no-cache'
      return result
   end
end

use DisableCache
set :public, File.dirname(__FILE__)

get '/' do
   redirect '/bin/debug.html'
end
