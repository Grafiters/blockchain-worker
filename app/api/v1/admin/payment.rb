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
                         }), with: API::V1::Admin::Entities::Payment
                    end

                    desc 'update payment method data'
                    params do
                        optional :name,
                                type: String,
                                desc: -> { API::V1::Admin::Entities::Payment.documentation[:name] }
                        optional :symbol,
                                type: String,
                                desc: -> { API::V1::Admin::Entities::Payment.documentation[:name] }
                        optional :logo_url,
                                type: String,
                                desc: -> { API::V1::Admin::Entities::Payment.documentation[:name] }
                        optional :base_color,
                                type: String,
                                desc: -> { API::V1::Admin::Entities::Payment.documentation[:name] }
                        optional :state,
                                type: String,
                                desc: -> { API::V1::Admin::Entities::Payment.documentation[:name] }
                        optional :tipe,
                                type: String,
                                desc: -> { API::V1::Admin::Entities::Payment.documentation[:name] }
                    end
                    put '/:id/update' do
                        declare_params = declared(params, include_missing: false)

                        payment = ::P2pPayment.find_by(id: params[:id])
                        payment.update(declare_params)
                    end
                end
            end
        end
    end
end