# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'
require 'logger'
require_relative 'constants'

# All methods related to launch darkly api are defined here
class LaunchdarklyApiHelperClass

  @launch_darkly_flags = 'https://app.launchdarkly.com/api/v2/flags/project_name'

  def initialize(access_token, project_name, log_file)
    @access_token = access_token
    @launch_darkly_flags.gsub! 'project_name', project_name
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
    request_url = "#{@launch_darkly_flags}/#{flag}?env=#{env}"
    ld_request(:get, request_url)
  end

  def fetch_flag_toggle_status(env, flag)
    flag_details_response = fetch_flag_details(env, flag)
    flag_details_response['environments'][env]['on']
  end

  def create_flag(key, name, description, tags)
    request_url = @launch_darkly_flags
    request_body = {}
    request_body.merge!(key: key, name: name, description: description, tags: tags)
    ld_request(:post, request_url, request_body)
  end

  def toggle_specific_environment(env, flag, flag_value)
    request_url = "#{@launch_darkly_flags}/#{flag}"
    request_body = { 'op' => 'replace', 'path' => "/environments/#{env}/on", 'value' => flag_value }
    response_body = ld_request(:patch, request_url, [request_body])
    response_body['environments'][env]['on']
  end

  def feature_flag_variation_index(status_response, details_response)
    variations = details_response['variations']
    value_at_index = -1
    variations.length.times do |index|
      next unless variations[index]['value'].eql? status_response

      value_at_index = index
      break
    end
    value_at_index
  end

  def feature_flag_variation_value(details_response, index_response)
    details_response['variations'][index_response]['value']
  end

  def feature_flag_variation_name(details_response, index_response)
    details_response['variations'][index_response]['name']
  end

  def ld_toggle_variation_served(env, flag)
    details_response = fetch_flag_details(env, flag)
    toggle_status_response = fetch_flag_toggle_status(env, flag)
    variation_index_response = feature_flag_variation_index(toggle_status_response, details_response) # ['environments'][env]['fallthrough']['variation']
    variation_value_response = feature_flag_variation_value(details_response, variation_index_response) # ['variations'][variation_index_response]['value']
    variation_name_response = feature_flag_variation_name(details_response, variation_index_response)
    [toggle_status_response, variation_index_response, variation_value_response, variation_name_response]
  end

  def search_rule_index_clause_index(clause_name)
    rule_at_index = -1
    clause_at_index = -1
    @feature_flag_rules_list.length.times do |rule_index|
      @feature_flag_clauses_list = @feature_flag_rules_list[rule_index]['clauses']
      @feature_flag_clauses_list.length.times do |clause_index|
        next unless @feature_flag_clauses_list[clause_index]['attribute'].eql? clause_name

        rule_at_index = rule_index
        clause_at_index = clause_index
        break
      end
    end
    [rule_at_index, clause_at_index]
  end

  def search_value_index(rule_at_index, clause_at_index, clause_value)
    value_at_index = -1
    @feature_flag_values_list = @feature_flag_rules_list[rule_at_index]['clauses'][clause_at_index]['values']
    @feature_flag_values_list.length.times do |value_index|
      next unless @feature_flag_values_list[value_index].eql? clause_value

      value_at_index = value_index
      break
    end
    value_at_index
  end

  def rules_clauses_index(env, flag, clause_name)
    feature_flag_response = fetch_flag_details(env, flag)
    @feature_flag_rules_list = feature_flag_response['environments'][env]['rules']
    search_rule_index_clause_index(clause_name)
  end

  def get_values_from_clauses(env, flag, clause_name)
    rule_at_index, clause_at_index = rules_clauses_index(env, flag, clause_name)
    @feature_flag_rules_list[rule_at_index]['clauses'][clause_at_index]['values']
  end

  def add_values_to_clause(env, flag, clause_name, clause_value)
    rule_at_index, clause_at_index = rules_clauses_index(env, flag, clause_name)
    request_url = "#{@launch_darkly_flags}/#{flag}"
    request_body = { 'op' => 'add', 'path' => "/environments/#{env}/rules/#{rule_at_index}/clauses/#{clause_at_index}/values/0", 'value' => clause_value }
    ld_request(:patch, request_url, [request_body])
  end

  def remove_values_from_clause(env, flag, clause_name, clause_value)
    rule_at_index, clause_at_index = rules_clauses_index(env, flag, clause_name)
    value_at_index = search_value_index(rule_at_index, clause_at_index, clause_value)
    puts "value_index: #{value_at_index}"
    request_url = "#{@launch_darkly_flags}/#{flag}"
    request_body = { 'op' => 'test', 'path' => "/environments/#{env}/rules/#{rule_at_index}/clauses/#{clause_at_index}/values/#{value_at_index}", 'value' => clause_value },
                   { 'op' => 'remove', 'path' => "/environments/#{env}/rules/#{rule_at_index}/clauses/#{clause_at_index}/values/#{value_at_index}" }
    ld_request(:patch, request_url, request_body)
  end

  def delete_flag(flag)
    request_url = "#{@launch_darkly_flags}/#{flag}"
    ld_request(:delete, request_url)
  end
end
