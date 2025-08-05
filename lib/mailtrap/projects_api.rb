# frozen_string_literal: true

require_relative 'base_api'
require_relative 'project'

module Mailtrap
  class ProjectsAPI
    include BaseAPI

    self.supported_options = %i[name]

    self.response_class = Project

    # Lists all email templates for the account
    # @return [Array<EmailTemplate>] Array of template objects
    # @!macro api_errors
    def list
      base_list
    end

    # Retrieves a specific project
    # @param project_id [Integer] The project ID
    # @return [Project] Project object
    # @!macro api_errors
    def get(project_id)
      base_get(project_id)
    end

    # Creates a new project
    # @param [Hash] options The parameters to create
    # @option options [String] :name The project name
    # @return [EmailTemplate] Created project object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def create(options)
      base_create(options)
    end

    # Updates an existing project
    # @param project_id [Integer] The project ID
    # @param [Hash] options The parameters to update
    # @return [Project] Updated project object
    # @!macro api_errors
    # @raise [ArgumentError] If invalid options are provided
    def update(project_id, options)
      base_update(project_id, options)
    end

    # Deletes a project
    # @param project_id [Integer] The project ID
    # @return nil
    # @!macro api_errors
    def delete(project_id)
      base_delete(project_id)
    end

    private

    def base_path
      "/api/accounts/#{account_id}/projects"
    end

    def wrap_request(options)
      { project: options }
    end
  end
end
