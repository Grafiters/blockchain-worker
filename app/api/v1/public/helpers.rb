module API
    module V1
        module Public
            module Helpers
                def verified_user(p2p_user)
                    member = P2pUser.joins(:member).find_by(member_id: p2p_user)
                end

                def pairs
                    ::P2pPair.find_by({fiat: params[:fiat], currency: params[:currency]})
                end

                def payment(uid)
                    ::P2pPaymentUser.joins(:p2p_order_payment, :p2p_payment)
                                                    .select("p2p_payments.*","p2p_order_payments.*","p2p_order_payments.id as p2p_payments")
                                                    .where(p2p_order_payments: {p2p_offer_id: uid})
                end

                def trader(uid)
                    ::Member.joins(:p2p_user).select("members.*","p2p_users.*").find_by(p2p_users: {id: uid})
                end
            end
        end
    end
end