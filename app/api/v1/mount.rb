# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'v1/validations'

module API
  module V1
    class Mount < Grape::API
      API_VERSION = 'v1'

      format         :json
      content_type   :json, 'application/json'
      default_format :json

      helpers API::V1::Helpers

      do_not_route_options!

      logger Rails.logger.dup
      if Rails.env.production?
        logger.formatter = GrapeLogging::Formatters::Json.new
      else
        logger.formatter = GrapeLogging::Formatters::Rails.new
      end
      use GrapeLogging::Middleware::RequestLogger,
          logger:    logger,
          log_level: :info,
          include:   [GrapeLogging::Loggers::Response.new,
                      GrapeLogging::Loggers::FilterParameters.new,
                      GrapeLogging::Loggers::ClientEnv.new,
                      GrapeLogging::Loggers::RequestHeaders.new]

      include Constraints
      include ExceptionHandlers

      mount API::V1::Public::Mount       => :public
      mount API::V1::Admin::Mount        => :admin
      mount API::V1::Market::Mount       => :market
      mount API::V1::Account::Mount      => :account

      add_swagger_documentation base_path:   File.join(API::Mount::PREFIX, 'v2', 'p2p'),
                                add_base_path: true,
                                mount_path:  '/swagger',
                                api_version: API_VERSION,
                                doc_version: Peatio::Application::VERSION,
                                info: {
                                  title:         "Nagap2p User API #{API_VERSION}",
                                  description:   'API for p2p platform application.',
                                  contact_name:  'nagap2p.co.id',
                                  contact_email: 'hello@nagap2p.co.id',
                                  contact_url:   'https://dev.heavenexchange.io',
                                },
                                models: [
                                  # API::V2::Entities::Currency,
                                ],
                                security_definitions: {
                                  Bearer: {
                                    type: "apiKey",
                                    name: "JWT",
                                    in:   "header"
                                  }
                                }

      # Mount Management API after swagger. To separate swagger Management API doc.
      # TODO: Find better solution for separating swagger Management API.
      # mount Management::Mount => :management
      # mount API::V1::Admin::Mount      => :admin
    end
  end
end
