module API
    module V1
        module Public
            class Payment < Grape::API
                namespace :payments do
                    desc 'Get available fiat'
                    get "/:fiat" do
                        payment = ::P2pPayment.joins(:fiat).where(fiats: {name: params[:fiat]})

                        present payment, with: ::API::V1::Public::Entities::Payment
                    end
                end
            end
        end
    end
end