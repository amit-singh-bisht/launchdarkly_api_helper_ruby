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
  # env, flag
  #
  # == Here, 'developer_flag_for_regression' is the feature flag name and default is our Project name - eg. AmitSinghBisht
  # == By default, this returns the configurations for all environments
  # == You can filter environments with the env query parameter. For example, setting env=staging restricts the returned configurations to just the staging environment
  # https://app.launchdarkly.com/api/v2/flags/default/developer_flag_for_regression?env=staging

  def ld_fetch_flag_details(env, flag)
    @launchdarkly_helper.fetch_flag_details(env, flag)
  end

  # == Get toggle status feature flag
  #
  # == key (*required)
  # env, flag
  #
  # response = https://app.launchdarkly.com/api/v2/flags/default/developer_flag_for_regression?env=staging
  # grab the value of the ['environments'][env]['on'] obtained from the above response

  def ld_fetch_flag_toggle_status(env, flag)
    @launchdarkly_helper.fetch_flag_toggle_status(env, flag)
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

  def ld_create_flag(key, name = key, description = key, tags = ['created_via_regression_api'])
    @launchdarkly_helper.create_flag(key, name, description, tags)
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

  def ld_toggle_flag_for_specific_environment(env, flag, flag_value = true)
    @launchdarkly_helper.toggle_flag_for_specific_environment(env, flag, flag_value)
  end

  # == Get status of feature flag
  # https://apidocs.launchdarkly.com/tag/Feature-flags#operation/patchFeatureFlag
  #
  # [fetch_flag_toggle_status_response, feature_flag_variation_index_response, feature_flag_variation_value_response, feature_flag_variation_name_response]

  def ld_toggle_variation_served_status(env, flag)
    @launchdarkly_helper.toggle_variation_served_status(env, flag)
  end

  def delete_flag(flag)
    request_url = "#{LAUNCH_DARKLY_FLAGS}/#{flag}"
    ld_request(:delete, request_url)
  end
end
