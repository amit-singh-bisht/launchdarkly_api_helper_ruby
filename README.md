# LaunchdarklyApiHelper ![alt_text](https://badge.fury.io/rb/launchdarkly_api_helper.svg)

[LaunchDarklyApiHelper](https://rubygems.org/gems/launchdarkly_api_helper) provides you a way to access your [Launch Darkly](https://apidocs.launchdarkly.com/) account using [API token](https://app.launchdarkly.com/settings/authorization/tokens/new) to view, edit or delete them accordingly.

![alt text](https://docs.launchdarkly.com/static/de107a76f0cd388da14d5bd650ec1f5c/b8471/settings-access-tokens-obscured-callout.png)

[Launch Darkly API Documentation](https://apidocs.launchdarkly.com/)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add launchdarkly_api_helper

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install launchdarkly_api_helper

## Usage

add `require 'launchdarkly_api_helper'` line at the beginning of your Ruby file

add `include LaunchdarklyApiHelper` line to access LaunchdarklyApiHelper module in gem _launchdarkly_api_helper_

To perform any operations such as add, remove, replace, move, copy, test you should have a working knowledge of [JSON Patch](https://datatracker.ietf.org/doc/html/rfc6902)

```ruby
parameters:
access_token (*required): this token will be used to send all requests to LaunchDarkly (string)
log_file: all logs will be writeen to file 'launchdarkly.log' by default if no file name specified

# set your LD API token and log file to capture logs
def ld_access_token(access_token, log_file = 'launchdarkly.log') 
  # code ...
end
```

[Get feature flag](https://apidocs.launchdarkly.com/tag/Feature-flags#operation/getFeatureFlag)

```ruby
GET REQUEST
https://app.launchdarkly.com/api/v2/flags/default/developer_flag_for_regression

parameters:
env (*required): name of the environment for which you want to get the details (string)
flag (*required): name of the feature flag for which you want to get the details (string)
                                             
Here, 'developer_flag_for_regression' is the feature flag name and default is our Project name - eg. AmitSinghBisht
By default, this returns the configurations for all environments
You can filter environments with the env query parameter. For example, setting env=staging restricts the returned configurations to just the staging environment
https://app.launchdarkly.com/api/v2/flags/default/developer_flag_for_regression?env=staging

# this method will give you entire details about a flag for that particular environment
def ld_fetch_flag_details(env, flag)
  # code ...
end

@return parameter: (response of feature flag details)
response = "https://app.launchdarkly.com/api/v2/flags/default/#{flag}?env=#{env}" (string)
```

```ruby
Get toggle status feature flag

parameters:
env (*required): name of the environment for which you want to get the details (string) 
flag (*required): name of the feature flag for which you want to get the details (string)

response = https://app.launchdarkly.com/api/v2/flags/default/developer_flag_for_regression?env=staging
grab the value of the ['environments'][env]['on'] obtained from the above response

# this method will return the status of the flag, whether it is on or off viz set to true or false
def ld_fetch_flag_toggle_status(env, flag)
  # code ...
end

@return parameter: (response of feature flag toggle status)
response = "https://app.launchdarkly.com/api/v2/flags/default/#{flag}?env=#{env}"
response['environments'][env]['on'] (boolean)
```

```ruby
Create a feature flag
https://apidocs.launchdarkly.com/tag/Feature-flags/#operation/postFeatureFlag

POST REQUEST
https://app.launchdarkly.com/api/v2/flags/default

Here, default is our Project name - eg. AmitSinghBisht

parameters:
key (*required): A unique key used to reference the feature flag in your code (string)
name (*required): A human-friendly name for the feature flag (string)
description: Description of the feature flag. Defaults to an empty string (string)
tags: Tags for the feature flag. Defaults to an empty array (Array of strings)
variations: An array of possible variations for the flag. The variation values must be unique. If omitted, two boolean variations of true and false will be used (Array of objects)

defaults
  * onVariation (*required): The index, from the array of variations for this flag, of the variation to serve by default when targeting is on (integer)
  * offVariation (*required): The index, from the array of variations for this flag, of the variation to serve by default when targeting is off (integer)

{
  "key": "developer_flag_for_regression",
  "name": "developer_flag_for_regression",
  "description": "developer_flag_for_regression is created via regression api on 18_10_2022",
  "tags": [
    "created_via_regression_api_on_18_10_2022"
  ],
  "variations": [
    {
      "age": 10
    },
    {
      "age": 20
    }
  ],
  "defaults": {
    "onVariation": 1,
    "offVariation": 0
  }
}

Above code will create a key 'developer_flag_for_regression' with name as 'developer_flag_for_regression' and description as 'developer_flag_for_regression is created via regression api on 18_10_2022'

Variations are provided while creating key, by default variation is a boolean value (true and false). once flag with a specific variation is created, its type cannot be modified later, hence choose your variation type smartly (Boolean, String, Number, JSON) In above example we are creating a flag with JSON type and its two values are 'age': 10 and 'age': 20

Also, variation has by default two values, and you must also define two variations while creating your own custom feature flag

Default will specify which variation to serve when flag is on or off. In above example when flag is turned on, '1' variation is served [Note: 0 and 1 are index position], so variations at first index ie variations[1] will be served when flag is turned on ie 'age': 20

# this method will create a new feature flag, NOTE: feature falg are created at global level and environment resides inside feature flag
def ld_create_flag(key, name = key, description = key, tags = ['created_via_regression_api'])
  # code ...
end
```

```ruby
Update feature flag
https://apidocs.launchdarkly.com/tag/Feature-flags#operation/patchFeatureFlag

PATCH REQUEST
https://app.launchdarkly.com/api/v2/flags/default/developer_flag_for_regression

parameters:
env (*required): name of the environment for which you want to get the details (string)
flag (*required): name of the feature flag for which you want to get the details (string)
flag_value: status of the feature flag that you want to set either on (true) or off (false) (boolean)

Here, 'developer_flag_for_regression' is the flag key and default is our Project name - eg. AmitSinghBisht
You can update any parameter of feature flag using this method

# this method will be used to toggle status of feature flag either on / off for a particular environment
def ld_toggle_specific_environment(env, flag, flag_value = true)
  # code ...
end

@return parameter: (response of feature flag toggle status)
response = "https://app.launchdarkly.com/api/v2/flags/default/#{flag}?env=#{env}"
response['environments'][env]['on'] (boolean)
```

```ruby
Get status of feature flag
https://apidocs.launchdarkly.com/tag/Feature-flags#operation/patchFeatureFlag

parameters:
env (*required): name of the environment for which you want to get the details (string)
flag (*required): name of the feature flag for which you want to get the details (string)

def ld_toggle_variation_served(env, flag)
  # code ...
end

@returns: [fetch_flag_toggle_status_response, feature_flag_variation_index_response, feature_flag_variation_value_response, feature_flag_variation_name_response]
@return parameter:
response = "https://app.launchdarkly.com/api/v2/flags/default/#{flag}?env=#{env}"
fetch_flag_toggle_status_response: response['environments'][env]['on'] (boolean)
feature_flag_variation_index_response: response (integer)
feature_flag_variation_value_response: response['variations'][feature_flag_variation_index_response]['value'] (object)
feature_flag_variation_name_response: response['variations'][feature_flag_variation_index_response]['name'] (string)
```

```ruby

"rules": [
  {                                   # rules/0
    "variation": 0,
    "clauses": [
      {                               # rules/0/clauses/0
        "attribute": "groups",
        "op": "in",
        "values": ["Top Customers"],
        "negate": false
      },
      {                               # rules/0/clauses/1
        "attribute": "email",
        "op": "endsWith",
        "values": ["gmail.com"],
        "negate": false
      }
    ]
  },
  {                                   # rules/1
    "variation": 1,
    "clauses": [
      {                               # rules/1/clauses/0
        "attribute": "country",
        "op": "in",
        "values": [
          "in",                       # rules/1/clauses/0/values/0
          "eu"                        # rules/1/clauses/0/values/1
        ],
        "negate": false
      }
    ]
  }
]

parameters:
env (*required): name of the environment for which you want to get the details (string)
flag (*required): name of the feature flag for which you want to get the details (string)
clause_name (*required): name of clause that you want to search for in response

def ld_rules_clauses_index(env, flag, clause_name)
  # code ...
end

@returns: [rule_at_index, clause_at_index]
@return parameter:
response = "https://app.launchdarkly.com/api/v2/flags/default/#{flag}?env=#{env}" ['environments'][env]['rules']
rule_at_index = response[rule_index] # index at which rule is found
clause_at_index = response[rule_index]['clauses'][clause_index] # index at which clause is found 
```

```ruby
parameters:
env (*required): name of the environment for which you want to get the details (string)
flag (*required): name of the feature flag for which you want to get the details (string)
clause_name (*required): name of clause that you want to search for in response

def ld_get_values_from_clauses(env, flag, clause_name)
  # code ...
end

@return parameter: values_for_clause_name
response = "https://app.launchdarkly.com/api/v2/flags/default/#{flag}?env=#{env}" ['environments'][env]['rules']
values_for_clause_name = response[rule_at_index]['clauses'][clause_at_index]['values']
```

```ruby
parameters:
env (*required): name of the environment for which you want to get the details (string)
flag (*required): name of the feature flag for which you want to get the details (string)
clause_name (*required): name of clause that you want to search for in response
clause_value (*required): value that you want to add to a particular clause (NOTE: it will be appened at zeroth 0th index)

def ld_add_values_to_clause(env, flag, clause_name, clause_value)
  # code ...
end

@return parameter: (response of feature flag details)
response = "https://app.launchdarkly.com/api/v2/flags/default/#{flag}?env=#{env}"
```

```ruby
parameters:
env (*required): name of the environment for which you want to get the details (string)
flag (*required): name of the feature flag for which you want to get the details (string)
clause_name (*required): name of clause that you want to search for in response
clause_value (*required): value that you want to add to a particular clause (NOTE: it will be appened at zeroth 0th index)

def ld_remove_values_from_clause(env, flag, clause_name, clause_value)
  # code ...
end

@return parameter: (response of feature flag details)
response = "https://app.launchdarkly.com/api/v2/flags/default/#{flag}?env=#{env}"
```

```ruby
Delete feature flag
https://apidocs.launchdarkly.com/tag/Feature-flags#operation/deleteFeatureFlag

DELETE REQUEST
https://app.launchdarkly.com/api/v2/flags/default/developer_flag_for_regression

Here, 'developer_flag_for_regression' is the flag key and default is our Project name - eg. AmitSinghBisht
You can delete any feature flag using this method

parameters:
flag (*required): name of the feature flag for which you want to get the details (string)

def ld_delete_flag(flag)
  # code ...
end

@return parameter: (response of feature flag details)
response = "https://app.launchdarkly.com/api/v2/flags/default/#{flag}?env=#{env}"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/launchdarkly_api_helper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/launchdarkly_api_helper/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LaunchdarklyApiHelper project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/launchdarkly_api_helper/blob/master/CODE_OF_CONDUCT.md).
