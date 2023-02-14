module API
    module V1
        module Account
            class Feedback < Grape::API
                helpers ::API::V1::Account::ParamHelpers

                # after_save :update_assesment

                namespace :feedback do
                    desc 'desc all Feedback on Order'
                    get do
                        present ::P2pOrder.all
                    end
                end
            end
        end
    end
end