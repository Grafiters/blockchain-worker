module API
    module V1
        module Admin
            class Config < Grape::API
                helpers ::API::V1::Account::ParamHelpers

                namespace :configs do
                    desc 'Returns all configs.'
                    params do
                        optional :name,
                                type: String,
                                desc: 'Filter by name.'
                        optional :value,
                                type: String
                    end
                    get do
			            config = ::P2pSetting.select("id, name, value, comment, created_at, updated_at").order(id: :desc)
			            present config
                    end

                    desc 'Create new Configs'
                    params do
                        requires :name,
                                type: String
                        requires :value,
                                type: String
                        optional :type,
                                type: String
                        optional :comment,
                                type: String
                    end
                    post do
                        setting = ::P2pSetting.find_by(name: params['name'])
                        error!({ errors: ['admin.p2p_order.can_not_send_message_order_is_done'] }, 422) unless setting.blank?
                        config = ::P2pSetting.create(
                            name: params[:name],
                            value: params[:value],
                            type: params[:type],
                            comment: params[:comment]
                        )

                        present config
                    end

                    params do
                        optional :value,
                                type: String,
                                desc: 'Declared Parameter value setting'
                    end
                    post ':id/update' do
                        setting = ::P2pSetting.find_by(id: params[:id])
                        
                        if setting.update(value: params[:value])
                            present setting
                        else
                            body errors: setting.errors.full_messages
                            status 422
                        end
                    end
                end
            end
        end
    end
end
