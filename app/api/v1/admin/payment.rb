module API
    module V1
        module Admin
            class Payment < Grape::API
                namespace :payments do
                    desc 'desc all fiat config admin'
                    get do
                        
                    end
                end
            end
        end
    end
end