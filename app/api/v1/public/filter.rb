module API
    module V1
        module Public
            class Filter < Grape::API
                namespace :fiats do
                    desc 'Filter available fiat Currency'
                    params do
                        requires :fiat,
                                type: String,
                                desc: -> { V2::Entities::Market.documentation[:symbol] }
                        optional :ordering,
                                values: { value: %w(asc desc), message: 'public.markets.invalid_ordering' },
                                default: 'asc',
                                desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
                    end
                    get "/filter" do
                        currency = ::P2pPair.where(fiat: params[:fiat])
                        paymen = ::P2pPayment.joins(:fiat).where(fiats: {name: params[:fiat]})

                        present :fiat, params[:fiat]
                        present :currency, currency, with: API::V1::Entities::Currency
                        present :payment, paymen, with: API::V1::Public::Entities::Payment
                    end
                end
            end
        end
    end
end