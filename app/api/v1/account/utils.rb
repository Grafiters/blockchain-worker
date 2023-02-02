# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
        module Account
            module Utils
                extend ::Grape::API::Helpers
                
                def current_p2p_user
                    ::P2pUser.joins(:member).find_by(members: {uid: current_user[:uid]})
                end

                def payments(payment)
                    ::P2pPaymentUser.joins(:p2p_order_payment, :p2p_payment)
                                                            .select("p2p_payments.*","p2p_order_payments.*")
                                                            .find_by(p2p_order_payments: {id: payment})
                end

                def buyorsel(uid)
                    data = ::P2pUser.joins(:member)
                                    .select("p2p_users.*", "members.*")
                                    .find_by(p2p_users: {id: uid})
                    if data.present?
                        data[:email] = email_data_masking(data[:email])
                    else
                        []
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
            end
        end
    end
end