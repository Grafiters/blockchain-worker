module API
    module V1
        module Admin
            class Payment < Grape::API
                namespace :payments do
                    desc 'desc all fiat config admin'
                    params do
                        optional :code_fiat,
                                type: String,
                                desc: -> { V1::Entities::Fiat.documentation[:code] }
                    end
                    get do
                        fiat_code = params[:code_fiat]
                        search_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                                        .eq(:fiat)
                                        .build

                        present paginate(Rails.cache.fetch("offers_#{params}", expires_in: 600) { 
                            ::P2pPayment.ransack(search_params).result.load.to_a
                         }), with: API::V1::Entities::Payment
                    end
                end
            end
        end
    end
end