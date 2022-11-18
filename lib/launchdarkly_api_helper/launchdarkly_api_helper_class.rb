# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'
require 'logger'
require_relative 'constants'

# All methods related to launch darkly api are defined here
class LaunchdarklyApiHelperClass
  def initialize(access_token, log_file)
    @access_token = access_token
    @logger = Logger.new(log_file)
  end

  def parse_json(json)
    JSON.parse(json)
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
    @response = parse_json(response.read_body)
  end

  def fetch_flag_details(env, flag)
    request_url = "#{LAUNCH_DARKLY_FLAGS}/#{flag}?env=#{env}"
    ld_request(:get, request_url)
  end

  def fetch_flag_toggle_status(env, flag)
    flag_details_response = fetch_flag_details(env, flag)
    flag_details_response['environments'][env]['on']
  end

  def create_flag(key, name, description, tags)
    request_url = LAUNCH_DARKLY_FLAGS
    request_body = {}
    request_body.merge!(key: key, name: name, description: description, tags: tags)
    ld_request(:post, request_url, request_body)
  end

  def toggle_flag_for_specific_environment(env, flag, flag_value)
    request_url = "#{LAUNCH_DARKLY_FLAGS}/#{flag}"
    request_body = { 'op' => 'replace', 'path' => "/environments/#{env}/on", 'value' => flag_value }
    response_body = ld_request(:patch, request_url, [request_body])
    response_body['environments'][env]['on']
  end

  def feature_flag_variation_index(fetch_flag_toggle_status_response, fetch_flag_details_response)
    variations = fetch_flag_details_response['variations']
    value_at_index = -1
    variations.length.times do |index|
      next unless variations[index]['value'].eql? fetch_flag_toggle_status_response

      value_at_index = index
      break
    end
    value_at_index
  end

  def feature_flag_variation_value(fetch_flag_details_response, feature_flag_variation_index_response)
    fetch_flag_details_response['variations'][feature_flag_variation_index_response]['value']
  end

  def feature_flag_variation_name(fetch_flag_details_response, feature_flag_variation_index_response)
    fetch_flag_details_response['variations'][feature_flag_variation_index_response]['name']
  end

  def toggle_variation_served_status(env, flag)
    fetch_flag_details_response = fetch_flag_details(env, flag)
    fetch_flag_toggle_status_response = fetch_flag_toggle_status(env, flag)
    feature_flag_variation_index_response = feature_flag_variation_index(fetch_flag_toggle_status_response, fetch_flag_details_response) # ['environments'][env]['fallthrough']['variation']
    feature_flag_variation_value_response = feature_flag_variation_value(fetch_flag_details_response, feature_flag_variation_index_response) # ['variations'][feature_flag_variation_index_response]['value']
    feature_flag_variation_name_response = feature_flag_variation_name(fetch_flag_details_response, feature_flag_variation_index_response)
    [fetch_flag_toggle_status_response, feature_flag_variation_index_response, feature_flag_variation_value_response, feature_flag_variation_name_response]
  end

  def search_value_in_hash(feature_flag_hash, attribute)
    value_at_index = -1
    feature_flag_hash.length.times do |index|
      next unless feature_flag_hash[index].to_s.include? attribute.to_s

      value_at_index = index
      break
    end
    value_at_index
  end

  def feature_flag_rules_clauses_index(flag, attribute, env = ENV['PROFILE'])
    @feature_flag_response = fetch_flag(flag, env)
    feature_flag_env = @feature_flag_response['environments'][env]
    @feature_flag_env_rules = feature_flag_env['rules']
    rule_index = search_value_in_hash(@feature_flag_env_rules, attribute)
    @feature_flag_env_rules_clauses = @feature_flag_env_rules[rule_index]['clauses']
    clause_index = search_value_in_hash(@feature_flag_env_rules_clauses, attribute)
    [rule_index, clause_index]
  end

  def feature_flag_add_values_to_rules(flag, attribute, value, env = ENV['PROFILE'])
    @flag = flag
    @attribute = attribute
    @value = value
    @rule_index, @clause_index = feature_flag_rules_clauses_index(flag, attribute)
    request_url = "#{LAUNCH_DARKLY_FLAGS}/#{flag}"
    request_body = { 'op' => 'add', 'path' => "/environments/#{env}/rules/#{@rule_index}/clauses/#{@clause_index}/values/0", 'value' => value }
    ld_request(:patch, request_url, [request_body])
  end

  def feature_flag_remove_values_to_rules(flag = @flag, attribute = @attribute, value = @value, env = ENV['PROFILE'])
    @rule_index, @clause_index = feature_flag_rules_clauses_index(flag, attribute, env = ENV['PROFILE']) unless flag || attribute
    feature_flag_env_rules_clauses_values = @feature_flag_env_rules_clauses[@clause_index]['values']
    value_index = search_value_in_hash(feature_flag_env_rules_clauses_values, value)
    request_url = "#{LAUNCH_DARKLY_FLAGS}/#{flag}"
    request_body = { 'op': 'test', 'path': "/environments/#{env}/rules/#{@rule_index}/clauses/#{@clause_index}/values/#{value_index}", 'value': value }, { 'op' => 'remove', 'path' => "/environments/#{env}/rules/#{@rule_index}/clauses/#{@clause_index}/values/#{value_index}" }
    ld_request(:patch, request_url, request_body)
  end
end
