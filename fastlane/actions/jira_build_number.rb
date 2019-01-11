module Fastlane
  module Actions
    module SharedValues
      JIRA_BUILD_NUMBER_CUSTOM_VALUE = :JIRA_BUILD_NUMBER_CUSTOM_VALUE
    end

    class JiraBuildNumberAction < Action
      def self.run(params)
        Actions.verify_gem!('jira-ruby')
        Actions.verify_gem!('rest-client')
        Actions.verify_gem!('json')
        require 'jira-ruby'
        require 'rest-client'
        require 'json'

        UI.message("Running Jira build number action...")
        
        commitMessage = params[:commit_message]
        jiraTicketId = searchForJiraIssueId(commitMessage)
        site = params[:url]
        auth_type = :basic
        username = params[:username]
        api_token = params[:token]
        build_number = params[:build_number]

        jiraBasicToken = Base64.encode64("#{username}:#{api_token}")
        converted_build = build_number.to_i
        build_fields = {"customfield_10637" => converted_build}
        payload = {"fields" => build_fields}.to_json

        UI.message "payload: #{payload}"
        UI.message "Jira ticket id: #{jiraTicketId}"
        UI.message "Commit message: #{params[:commit_message]}"

        if(!jiraTicketId.nil?)
          response = RestClient.put "https://#{site}/rest/api/2/issue/#{jiraTicketId}/",
                                     payload,
                                    { content_type: "application/json", Authorization: "Basic #{jiraBasicToken}"}  
        end
        
      end

      def self.searchForJiraIssueId(str)
        /[A-Z]+[-](\d+)/.match(str)
      end
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This action updates a custom field in JIRA (for us build number)."
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        
        [
          FastlaneCore::ConfigItem.new(key: :token,
                                       env_name: "JIRA_API_TOKEN",
                                       description: "API Token for JiraBuildNumberAction",
                                       verify_block: proc do |value|
                                          UI.user_error!("No API token for JiraBuildNumberAction given, pass using `api_token: 'token'`") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "",
                                       description: "Email for JIRA account",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :commit_message,
                                       env_name: "",
                                       description: "Commit message for git commit",
                                       is_string: false, 
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: "",
                                       description: "ASAPP JIRA base url",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :build_number,
                                       env_name: "",
                                       description: "Build Number for the iOS-SDK project",
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['JIRA_BUILD_NUMBER_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Your GitHub/Twitter Name"]
      end

      def self.is_supported?(platform)
        # you can do things like
        # 
        #  true
        # 
        #  platform == :ios
        # 
        #  [:ios, :mac].include?(platform)
        # 

        platform == :ios
      end
    end
  end
end
