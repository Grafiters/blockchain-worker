module API
    module V2
        module Entities
            class Setting < Base
                expose :name,
                    type: String,
                    desc: 'The name of setting configuration'

                expose :value,
                    type: String,
                    desc: 'The value of setting configuration'
                    
            end
        end
    end
end