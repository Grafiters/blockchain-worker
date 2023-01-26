module API
    module V1
        module Admin
            class Fiat < Grape::API
                namespace :fiats do
                    desc 'desc all fiat config admin'
                    get do
                        present "this is fiat"
                    end
                end
            end
        end
    end
end