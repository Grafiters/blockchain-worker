module API
    module V1
        module Public
            class Fiat < Grape::API
                helpers ::API::V1::Admin::Helpers
                namespace :fiats do
                    desc 'Get available fiat'
                    get "/" do
                        ransack_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                             .eq(:code)
                             .build

                        search = ::Fiat.ransack(ransack_params)

                        search.sorts = ["name asc"]

                        present search.result.load.to_a, with: API::V1::Entities::Fiat
                    end
                end
            end
        end
    end
end