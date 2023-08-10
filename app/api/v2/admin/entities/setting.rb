module API
    module V2
        module Admin
            module Entities
                class Setting < API::V2::Entities::Setting
                    expose :id,
                        type: Integer,
                        desc: 'The identifier of setting configuration'             

                    expose(
                        :created_at,
                        format_with: :iso8601,
                        documentation: {
                            type: String,
                            desc: 'setting created time in iso8601 format.'
                        }
                    )

                    expose(
                        :updated_at,
                        format_with: :iso8601,
                        documentation: {
                            type: String,
                            desc: 'setting updated time in iso8601 format.'
                        }
                    )
                end
            end
        end
    end
end