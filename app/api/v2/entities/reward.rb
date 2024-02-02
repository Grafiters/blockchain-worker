module API
    module V2
        module Entities
            class Reward < Base
                expose :uid,
                    documentation: {
                        type: String,
                        desc: "uid for reward data"
                    }

                expose :refferal_member_id,
                    as: :refferal,
                    using: API::V2::Entities::Member,
                    documentation: {
                        type: String,
                        desc: "member who reward from"
                    } do |reward|
                        reward.refferal
                    end

                expose :reffered_member_id,
                    as: :reffered,
                    using: API::V2::Entities::Member,
                    documentation: {
                        type: String,
                        desc: "who reward member for"
                    } do |reward|
                        reward.reffered
                    end

                expose :amount,
                    documentation: {
                        type: String,
                        desc: "amount for reward data"
                    }

                expose :currency,
                    documentation: {
                        type: String,
                        desc: "currency for reward data"
                    }

                expose :type,
                    documentation: {
                        type: String,
                        desc: "type for reward data"
                    }
                    
                expose :is_process,
                    documentation: {
                        type: String,
                        desc: "is_process for reward data"
                    }
            end
        end
    end
end