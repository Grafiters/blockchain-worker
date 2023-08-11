module API
    module V2
        module Admin
            class Settings < Grape::API
                namespace :settings do
                    desc 'Get all settings options',
                        success: API::V2::Admin::Entities::Setting
                    get do
                        Setting.order(id: :desc)
                            .tap{ |q| present q, with: API::V2::Admin::Entities::Setting }
                    end

                    desc 'Create new setting configuration',
                        success: API::V2::Admin::Entities::Setting
                    params do
                        requires :name,
                            type: String,
                            desc: 'Name of the setting configuration, with format (text_text)'
                        requires :value,
                            type: String,
                            desc: 'Value of the setting configuration'
                        requires :description,
                            type: String,
                            desc: 'Description of the setting configuration'
                        requires :deleted,
                            type: String,
                            values: { value: %w(true false), message: 'admin.setting.invalid_status' },
                            desc: 'Field for the data is will deleted or not'
                    end
                    post do
                        error!(errors: ['admin.setting.invalid_format']) unless Setting.contains_space?(params[:name])

                        declared_params = declared(params, include_missing: false)
                        setting = Setting.new(declared_params)
                        if setting.save
                            present setting, with: API::V2::Admin::Entities::Setting
                        else
                            body errors: setting.errors.full_messages
                            status 422
                        end
                    end

                    desc 'Update data setting configuration'
                    params do
                        requires :id,
                            type: Integer,
                            desc: 'Setting identifier to update'
                        requires :name,
                            type: String,
                            desc: 'Name of the setting configuration, with format (text_text)'
                        requires :value,
                            type: String,
                            desc: 'Value of the setting configuration'
                        requires :description,
                            type: String,
                            desc: 'Description of the setting configuration'
                        requires :deleted,
                            type: String,
                            values: { value: %w(true false), message: 'admin.setting.invalid_status' },
                            desc: 'Field for the data is will deleted or not'
                    end
                    put 'update/:id' do
                        setting = Setting.find_by(id: params[:id])
                        error!(errors: ['admin.setting.invalid_format']) unless Setting.contains_space?(params[:name])
                        error!({errors: ['admin.setting.not_found']}, 422) unless setting.present?
                        declared_params = declared(params.except(:id), include_missing: false)
                        
                        error!({errors: ['admin.setting.data_can\'t_deleted']}, 422) unless setting.deleted?

                        if setting.update(declared_params)
                            present setting, with: API::V2::Admin::Entities::Setting
                        else
                            body errors: setting.errors.full_messages
                            status 422
                        end
                    end

                    desc 'Delete Setting configuration'
                    params do
                        requires :id,
                            type: Integer,
                            desc: 'Id of the setting configuration'
                    end
                    delete 'delete/:id' do
                        setting = Setting.find_by(id: params[:id])
                        error!({errors: ['admin.setting.not_found']}, 422) unless setting.present?

                        setting.destroy
                        200
                    end
                end
            end
        end
    end
end