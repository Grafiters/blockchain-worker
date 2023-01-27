module API
    module V1
        module Admin
            class Trade < Grape::API
                helpers ::API::V2::Admin::Helpers
                namespace :trades do
                    desc 'Filter available fiat'
                    params do
                        use :pagination
                        requires :type,
                                type: String,
                                desc: -> { V2::Entities::Market.documentation[:symbol] }
                    end
                    get "/" do
                        admin_authorize! :read, ::Market
                        result = ::P2pOffer.where(side: [params[:type]])
                                    .order(params[:order_by] => params[:ordering])                        
                        
                        present paginate(result)
                    end
                end
            end
        end
    end
end