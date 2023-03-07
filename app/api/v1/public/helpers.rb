module API
    module V1
        module Public
            module Helpers
                def params_offer_filter
                    params_map = {
                        min_order_amount: params[:amount]
                    }
                end

                def verified_user(p2p_user)
                    member = P2pUser.joins(:member).find_by(member_id: p2p_user)
                end

                def pairs
                    ::P2pPair.find_by({fiat: params[:fiat], currency: params[:currency]})
                end

                def payments(uid)
                    ::P2pPaymentUser.joins(:p2p_offer_payment, :p2p_payment)
                                                    .select("p2p_payments.*","p2p_offer_payments.*","p2p_offer_payments.id as p2p_payments")
                                                    .where(p2p_offer_payments: {p2p_offer_id: uid})
                end

                def buyorsel(uid)
                    data = ::P2pUser.joins(:member)
                                    .select("p2p_users.*", "members.*")
                                    .find_by(p2p_users: {id: uid})
                    if data.present?
                        data[:email] = email_data_masking(data[:email])
                    else
                        {}
                    end

                    data
                end

                def count_time_limit(p2p_start, p2p_end)
                    time = (p2p_end - p2p_start)

                    Time.at(time).utc.strftime("%H:%M:%S")
                end

                def email_data_masking(email)
                    if email.present?
                      email.downcase.sub(/(?<=[\w\d])[\w\d]+(?=[\w\d])/, '*****')
                    else
                      email
                    end
                end

                def sum_order(uid)
                    ::P2pOrder.where(p2p_offer_id: uid).count
                end

                def persentage(uid)
                    completed = ::P2pOrder.where(p2p_offer_id: uid).where(state: 'completed').count

                    completed > 0 ? (completed * 100) / sum_order(uid) : 0
                end

                def trader(uid)
                    ::Member.joins(:p2p_user).select("members.*","p2p_users.*").find_by(p2p_users: {id: uid})
                end

                def currency(fiat_id)
                    ::P2pPair.find_by(id: fiat_id)
                end
            end
        end
    end
end