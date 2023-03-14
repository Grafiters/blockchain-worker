# frozen_string_literal: true

module API
    module V1
      module Admin
        class Mount < Grape::API

          before { authenticate! unless request.path == '/api/v1/admin/swagger' }

          mount API::V1::Admin::Fiat
          mount API::V1::Admin::Order
          mount API::V1::Admin::Offer
          mount API::V1::Admin::Trade
          mount API::V1::Admin::Payment
          mount API::V1::Admin::Members
  
          add_swagger_documentation base_path: File.join(API::Mount::PREFIX, 'v2', 'p2p', 'admin'),
                                    add_base_path: true,
                                    mount_path:  '/swagger',
                                    api_version: API::V1::Mount::API_VERSION,
                                    doc_version: Peatio::Application::VERSION,
                                    info: {
                                      title:          "Admin API #{API::V1::Mount::API_VERSION}",
                                      description:    'Admin API high privileged API with RBAC.',
                                      contact_name:   'nagaexchange.co.id',
                                      contact_email:  'hello@nagaexchange.co.id',
                                      contact_url:    'https://www.nagaexchange.co.id',
                                    },
                                    models: [

                                    ]
        end
      end
    end
  end
  