module API
    module V1
        module Public
            class Offer < Grape::API
                helpers ::API::V1::Public::Helpers
                namespace :trades do
                    desc 'Filter available fiat'
                    params do
                        # use :pagination
                        requires :fiat,
                                type: String,
                                desc: -> { V1::Entities::Fiat.documentation[:code] }
                        requires :currency,
                                type: String,
                                desc: -> { V1::Entities::Fiat.documentation[:currency] }
                        requires :side,
                                type: String,
                                desc: 'Side Offer by Sell Or Buy'
                        optional :amount,
                                type: { value: Integer, message: 'market.offer.non_integer_limit' }
                        optional :max_amount,
                                type: { value: Integer, message: 'market.offer.non_integer_limit' }
                        optional :min_price,
                                type: { value: Integer, message: 'market.offer.non_integer_limit' }
                        optional :max_price,
                                type: { value: Integer, message: 'market.offer.non_integer_limit' }
                    end
                    get "/" do
                        search_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                                                .lt_any
                                                .with_range_price
                                                .build

                        side = params[:side] == 'buy' ? 'sell' : 'buy'

                        payment_filter = ::P2pPaymentUser.where(p2p_payment_id: params[:payment]).pluck(:id)
                        
                        offer = ::P2pOffer.joins(:p2p_pair)
                                            .select("p2p_offers.*","p2p_offers.offer_number as sum_order","p2p_offers.offer_number as persentage", "p2p_offers.p2p_user_id as member", "p2p_offers.p2p_pair_id as currency")
                                            .where(p2p_pairs: {fiat: params[:fiat]})
                                            .where(p2p_pairs: {currency: params[:currency]})
                                            .where(p2p_offers: {side: side})
                                            .where.not(p2p_offers: {state: 'canceled'})
                        
                        offer = params[:amount].blank? ? offer.where('p2p_offers.available_amount > 0') : offer.where('p2p_offers.available_amount > ?', params[:amount])
                        
                        offer = offer.with_payment(payment_filter) unless params[:payment].blank? || params[:payment][0].blank?
                        search = offer.ransack(search_params)

                        search.sorts = "id DESC"
                        
                        result = search.result.load
                        data = result.each do |offer|
                            offer[:sum_order] = sum_order(offer[:id])
                            offer[:persentage] = persentage(offer[:id])
                            offer[:currency] = currency(offer[:currency])[:currency].upcase
                            offer[:member] = trader(offer[:p2p_user_id])
                        end

                        # present params
                        present paginate(data), with: API::V1::Public::Entities::Offer
                    end

                    desc 'Get Detail of Offer Trade Number'
                    get "/detail/:offer_number" do
                        trade = ::P2pOffer.find_by(offer_number: params[:offer_number])

                        present trade
                    end

                    desc 'Get Detail Merchant Trade'
                    get "/merchant/:merchant" do
                        member = ::P2pUser.joins(:member).find_by(members: {uid: params[:merchant]})
                        error!({ errors: ['p2p_trade.merchant.merchant_doesn_not_exists'] }, 422) unless member.present?

                        feedback = ::P2pOrderFeedback.joins(p2p_order: :p2p_offer)
                                            .select("p2p_order_feedbacks.*", "p2p_orders.p2p_payment_user_id as payment", "p2p_orders.p2p_user_id as member",
                                            "p2p_orders.created_at as p2p_start","p2p_orders.updated_at as p2p_end", "p2p_orders.first_approve_expire_at as payment_limit")
                                            .where(p2p_offers: {p2p_user_id: member[:id]})

                        feedback.each do |feed |
                            feed[:payment] = payments(feed[:payment])
                            feed[:member] = buyorsel(feed[:member])
                            feed[:payment_limit]   = count_time_limit(feed[:p2p_start], feed[:p2p_end])
                        end

                        present :merchant, member, with: API::V1::Public::Entities::Merchant
                        present :feedbacks, feedback, with: API::V1::Public::Entities::Feedback
                    end
                end
            end
        end
    end
end