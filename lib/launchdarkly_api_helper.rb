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

# LaunchDarklyApiHelper provides you a way to access your Launch Darkly account using API token to view, edit or delete them accordingly.
module LaunchdarklyApiHelper
  class Error < StandardError; end

  # set your LD API token and log file to capture logs
  def ld_access_token(access_token, project_name = 'default', log_file = 'launchdarkly.log')
    @launchdarkly_helper = LaunchdarklyApiHelperClass.new(access_token, project_name, log_file)
  end

  # this method will give you entire details about a flag for that particular environment
  def ld_fetch_flag_details(env, flag)
    @launchdarkly_helper.fetch_flag_details(env, flag)
  end

  # this method will return the status of the flag, whether it is on or off viz set to true or false
  def ld_fetch_flag_toggle_status(env, flag)
    @launchdarkly_helper.fetch_flag_toggle_status(env, flag)
  end

  # this method will create a new feature flag, NOTE: feature falg are created at global level and environment resides inside feature flag
  def ld_create_flag(key, name = key, description = key, tags = ['created_via_regression_api'])
    @launchdarkly_helper.create_flag(key, name, description, tags)
  end

  # this method will be used to toggle status of feature flag either on / off for a particular environment
  def ld_toggle_specific_environment(env, flag, flag_value = true)
    @launchdarkly_helper.toggle_specific_environment(env, flag, flag_value)
  end

  # this method will get important parameters from the response
  def ld_flag_variation_served(env, flag)
    @launchdarkly_helper.flag_variation_served(env, flag)
  end

  # this method will return the index of rules and clauses by searching for clause_name in response
  def ld_rules_clauses_index(env, flag, clause_name)
    @launchdarkly_helper.rules_clauses_index(env, flag, clause_name)
  end

  # this method will return values inside a particular clause by searching for clause_name in response
  def ld_get_values_from_clauses(env, flag, clause_name)
    @launchdarkly_helper.get_values_from_clauses(env, flag, clause_name)
  end

  # this method will help you to add a value to a particular clause by searching for clause_name in response
  def ld_add_values_to_clause(env, flag, clause_name, clause_value)
    @launchdarkly_helper.add_values_to_clause(env, flag, clause_name, clause_value)
  end

  # this method will help you to remove a value to a particular clause by searching for clause_name in response
  def ld_remove_values_from_clause(env, flag, clause_name, clause_value)
    @launchdarkly_helper.remove_values_from_clause(env, flag, clause_name, clause_value)
  end

  # this method will delete a feature flag in launchdarkly (NOTE: env resided inside flag which means flag is parent, so deleting a feature flag will delete it from all environment)
  def ld_delete_flag(flag)
    @launchdarkly_helper.delete_flag(flag)
  end
end
