# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
#
# class CorsWrapper
#   def initialize(app)
#     @app = app
#   end
#
#   def call(env)
#     status, headers, body = @app.call(env)
#     headers['Access-Control-Allow-Origin'] = '*'
#     headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
#     headers['Access-Control-Request-Method'] = '*'
#     headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
#
#     [status, headers, body]
#   end
# end

run Rails.application
