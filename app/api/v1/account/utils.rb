# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
        module Account
            module Utils
                extend ::Grape::API::Helpers
                
                def fiat(uid)
                    ::P2pOffer.find_by(id: uid)
                end

                def current_p2p_user
                    ::P2pUser.joins(:member).select("p2p_users.*","members.uid").find_by(members: {uid: current_user[:uid]})
                end

                def target_p2p_user
                    ::P2pUser.joins(:member).select("p2p_users.*","members.uid").find_by(members: {uid: params[:merchant]})
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

                def payment_order(offer)
                    ::P2pPaymentUser.joins(:p2p_payment, p2p_order_payment: :p2p_offer).select("p2p_payments.*","p2p_order_payments.*","p2p_payment_users.name as account_name","p2p_payment_users.account_number", "p2p_payment_users.payment_user_uid").where(p2p_offers: {id: offer[:id]})
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

                def p2p_user
                    # jwt.payload provided by rack-jwt
                    if request.env.key?('jwt.payload')
                      begin
                        ::P2pUser.from_payload(current_user)
                      # Handle race conditions when creating member record.
                      # We do not handle race condition for update operations.
                      # http://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_create_by
                      rescue ActiveRecord::RecordNotUnique
                        retry
                      end
                    end
                end
            end
        end
    end
end