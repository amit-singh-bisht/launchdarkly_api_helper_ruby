# frozen_string_literal: true

# The MIT License (MIT)
#
# Copyright (c) 2022 Amit Singh Bisht (https://github.com/amit-singh-bisht/)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'uri'
require 'json'
require 'net/http'
require 'logger'
require_relative 'launchdarkly_api_helper/constants'
require_relative 'launchdarkly_api_helper/launchdarkly_api_helper_class'

# All methods related to launch darkly api are defined here
module LaunchdarklyApiHelper
  class Error < StandardError; end

  # == LaunchDarkly REST API
  # https://apidocs.launchdarkly.com/
  # == To perform any operations such as add, remove, replace, move, copy, test you should have a working knowledge of JSON Patch
  # https://datatracker.ietf.org/doc/html/rfc6902

  def ld_access_token(access_token, log_file = 'launchdarkly.log')
    @launchdarkly_helper = LaunchdarklyApiHelperClass.new(access_token, log_file)
  end

  # == Get feature flag
  # https://apidocs.launchdarkly.com/tag/Feature-flags#operation/getFeatureFlag
  #
  # == GET REQUEST
  # https://app.launchdarkly.com/api/v2/flags/default/developer_flag_for_regression
  #
  # == key (*required)
  # env
  #
  # == Here, 'developer_flag_for_regression' is the flag key and default is our Project name - Browserstack
  # == By default, this returns the configurations for all environments
  # == You can filter environments with the env query parameter. For example, setting env=k8s restricts the returned configurations to just the k8s environment
  # https://app.launchdarkly.com/api/v2/flags/default/developer_flag_for_regression?env=k8s

  def fetch_flag(flag, env)
    request_url = "#{LAUNCH_DARKLY_FLAGS}/#{flag}?env=#{env}"
    @launchdarkly_helper.ld_request(:get, request_url)
  end

  # == Create a feature flag
  # https://apidocs.launchdarkly.com/tag/Feature-flags/#operation/postFeatureFlag
  #
  # == POST REQUEST
  # https://app.launchdarkly.com/api/v2/flags/default
  #
  # Here, default is our Project name - Browserstack
  #
  # key (*required): A unique key used to reference the flag in your code (string)
  #
  # name (*required): A human-friendly name for the feature flag (string)
  #
  # description: Description of the feature flag. Defaults to an empty string (string)
  #
  # tags: Tags for the feature flag. Defaults to an empty array (Array of strings)
  #
  # variations: An array of possible variations for the flag. The variation values must be unique. If omitted, two boolean variations of true and false will be used (Array of objects)
  #
  # defaults
  # * onVariation (*required): The index, from the array of variations for this flag, of the variation to serve by default when targeting is on (integer)
  # * offVariation (*required): The index, from the array of variations for this flag, of the variation to serve by default when targeting is off (integer)
  #
  #     {
  #       "key": "developer_flag_for_regression",
  #       "name": "developer_flag_for_regression",
  #       "description": "developer_flag_for_regression is created via regression
  #                       api on 18_10_2022",
  #       "tags": [
  #           "created_via_regression_api_on_18_10_2022"
  #       ],
  #       "variations": [
  #           {
  #               "age": 10
  #           },
  #           {
  #               "age": 20
  #           }
  #       ],
  #       "defaults": {
  #           "onVariation": 1,
  #           "offVariation": 0
  #       }
  #     }
  #
  # Above code will create a key 'developer_flag_for_regression' with name as 'developer_flag_for_regression' and description as 'developer_flag_for_regression is created via regression api on 18_10_2022'
  #
  # Variations are provided while creating key, by default variation is a boolean value (true and false). once flag with a specific variation is created, its type cannot be modified later, hence choose your variation type smartly (Boolean, String, Number, JSON) In above example we are creating a flag with JSON type and its two values are 'age': 10 and 'age': 20
  #
  # Also, variation has by default two values, and you must also define two variations while creating your own custom feature flag
  #
  # Default will specify which variation to serve when flag is on or off. In above example when flag is turned on, '1' variation is served [Note: 0 and 1 are index position], so variations at first index ie variations[1] will be served when flag is turned on ie 'age': 20

  def create_flag(key, name: key, description: key, tags: ['created_via_regression_api'])
    request_url = LAUNCH_DARKLY_FLAGS
    request_body = {}
    request_body.merge!(key: key, name: name, description: description, tags: tags)
    ld_request(:post, request_url, request_body)
  end

  # == Update feature flag
  # https://apidocs.launchdarkly.com/tag/Feature-flags#operation/patchFeatureFlag
  #
  # == PATCH REQUEST
  # https://app.launchdarkly.com/api/v2/flags/default/developer_flag_for_regression
  #
  # key (*required)
  #
  # == Here, 'developer_flag_for_regression' is the flag key and default is our Project name - Browserstack
  # == You can update any parameter of feature flag using this method

  def toggle_flag_for_specific_environment(env, flag, flag_value: true)
    request_url = "#{LAUNCH_DARKLY_FLAGS}/#{flag}"
    request_body = { 'op' => 'replace', 'path' => "/environments/#{env}/on", 'value' => flag_value }
    response_body = ld_request(:patch, request_url, [request_body])
    response_body['environments'][env]['on']
  end

  def toggle_variation_served_status(flag, env = ENV['PROFILE'])
    feature_flag_response = fetch_flag(flag, env)
    feature_flag_env = feature_flag_response['environments'][env]
    feature_flag_toggle_status = feature_flag_env['on']
    feature_flag_variation_index = feature_flag_env['fallthrough']['variation']
    feature_flag_variation = feature_flag_response['variations'][feature_flag_variation_index]
    feature_flag_variation_value = feature_flag_variation['value']
    feature_flag_variation_name = feature_flag_variation['name']
    [feature_flag_toggle_status, feature_flag_variation_value, feature_flag_variation_name]
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

  def delete_flag(flag)
    request_url = "#{LAUNCH_DARKLY_FLAGS}/#{flag}"
    ld_request(:delete, request_url)
  end
end


