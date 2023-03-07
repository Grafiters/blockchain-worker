module API
  class Mount < Grape::API
    PREFIX = '/api'

    cascade false

    mount API::V1::Mount => API::V1::Mount::API_VERSION
    mount API::V2::Mount => API::V2::Mount::API_VERSION
  end
end
