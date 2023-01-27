module API
    module V1
        module Public
            class Filter < Grape::API
                helpers ::API::V1::Admin::Helpers
                namespace :fiats do
                    desc 'Filter available fiat'
                    params do
                        use :pagination
                        optional :fiat,
                                type: String,
                                desc: -> { V2::Entities::Market.documentation[:symbol] }
                        optional :ordering,
                                values: { value: %w(asc desc), message: 'public.markets.invalid_ordering' },
                                default: 'asc',
                                desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
                    end
                    get "/filter" do
                        filter = {}

                        currency = ::P2pPair.where(fiat: params[:fiat])
                        paymen = ::P2pPayment.joins(:fiat).where(fiats: {name: params[:fiat]})

                        filter[:currency] = currency
                        filter[:paymen] = paymen
                        present filter
                    end
                end
            end
        end
    end
end