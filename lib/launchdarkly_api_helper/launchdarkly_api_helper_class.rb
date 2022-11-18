# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'
require 'logger'
# require_relative 'constants'

# All methods related to launch darkly api are defined here
class LaunchdarklyApiHelperClass
  def initialize(access_token, log_file)
    @access_token = access_token
    @logger = Logger.new(log_file)
  end

  def parse_json(json)
    puts "json: #{json}"
    # json.read_body.empty? ? JSON.parse(json) ? JSON.parse(json.read_body)
  end

  def convert_to_json(hash)
    JSON.dump(hash)
  end

  def ld_request(http_method, request_url, request_body = nil)
    url = URI(request_url)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = REQUEST_CLASSES[http_method]['method'].new(url)
    request['Authorization'] = @access_token
    request['Content-Type'] = 'application/json'
    request['LD-API-Version'] = 'beta'
    case http_method
    when :get, :patch, :post
      request.body = convert_to_json(request_body) unless http_method == :get
      https.request(request)
    when :delete
      return https.request(request)
    else
      raise StandardError, "Undefined HTTP method #{http_method} found"
    end
    response = https.request(request)
    puts "response: #{response}"
    JSON.parse(response.read_body)
  end
end
