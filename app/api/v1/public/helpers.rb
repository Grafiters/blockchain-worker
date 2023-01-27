module API
    module V1
        module Public
            class Helpers < Grape::API
                def verified_user(p2p_user)
                    member = P2pUser.joins(:member).find_by(member_id: p2p_user)
                    # member[:uid]
                end
            end
        end
    end
end