module API
    module V1
        module Admin
            class configs < Grape::API
                helpers ::API::V1::Account::ParamHelpers

                namespace :configs do
                    desc 'Returns all configs.'
                    params do
                        optional :name,
                                type: String,
                                desc: 'Filter by name.'
                        use :pagination
                        use :ordering
                    end
                    get do
                        config = ::P2pSetting.order(id: :desc)
                                .tap { |q| q.where!(name: params[:name]) }
                                .tap { |q| present paginate(q) }
                    end

                    desc 'Create new Configs'
                    params do
                        requires :name,
                                type: String
                        requires :value,
                                type: String
                    end
                    post do
                        config = ::P2pSetting.create(params)
                        present config
                    end
                end
            end
        end
    end
end