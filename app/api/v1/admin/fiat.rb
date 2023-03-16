module API
    module V1
        module Admin
            class Fiat < Grape::API
                helpers ::API::V1::Account::ParamHelpers

                namespace :fiats do
                    desc 'desc all fiat config admin'
                    params do
                        optional :name,
                                desc: 'return all fiat currency'
                        optional :symbol,
                                desc: 'will return fiat filtered by symbol'
                        optional :currency,
                                desc: 'will return fiat filtered by currency'
                    end
                    get do
                        ransack_params = Helpers::RansackBuilder.new(params)
                        
                        query = ::Fiat.joins(:p2p_pairs)
                        query = query.where(p2p_pairs: {currency: params[:currency]}) unless params[:currency].blank?

                        search = query.ransack(ransack_params)

                        present paginate(search.results)
                    end

                    desc 'create a new config fiat admin'
                    params do
                        requires :name,
                                desc: 'fiat name'
                        requires :symbol,
                                desc: 'fiat symbol'
                        requires :code,
                                desc: 'fiat code'
                        requires :icon_url,
                                desc: 'fiat icon_url'
                        optional :scale,
                                desc: 'scale amount fiat'
                        optional :taker_fee,
                                desc: 'fee of taker fiat'
                        optional :maker_fee,
                                desc: 'fee of maker fiat'
                    end
                    post do
                        validate_fiat
                        fiat = ::Fiat.create({
                            name: params[:name],
                            symbol: params[:symbol],
                            code: params[:code],
                            icon_url: params[:icon_url],
                            scale: params[:scale],
                            taker_fee: params[:taker_fee],
                            maker_fee: params[:maker_fee]
                        })

                        error!(fiat.errors.details, 422) unless fiat.save

                        present fiat, with: API::V1::Entities::Fiat
                    end

                    desc 'Fiat Currency'
                    get 'currency/:fiat' do
                        currency = ::Currency.pair.where(fiat: params[:fiat])

                        present fiat, with: API::V1::Entities::Currency
                    end

                    params do
                        requires :currency,
                                desc: 'currency code'
                        optional :taker_fee,
                                type: BigDecimal,
                                desc: 'fee of taker fiat'
                        optional :maker_fee,
                                type: BigDecimal,
                                desc: 'fee of maker fiat'
                    end
                    post 'currency/:fiat' do 
                        validate_pair
                        fiat = ::Fiat.find_by(params[:fiat])

                        params[:currency].each do |c|
                            pair = ::P2pPair.create(
                                fiat: params[:fiat],
                                currency: c,
                                taker_fee: params[:taker_fee].present? ? params[:taker_fee] : fiat[:taker_fee],
                                maker_fee: params[:maker_fee].present? ? params[:maker_fee] : fiat[:maker_fee]
                            )
                        end

                        present pair
                    end

                    desc 'Change state of fiat pair enabled or disabled'
                    params do
                        requires :state,
                                values: { value: %w(enabled disabled), message: 'admin.pair.invalid_actions_params' }
                    end
                    put 'currency/:id' do
                        pair = ::P2pPair.find_by_id(params[:id])
                        pair.update(state: params[:state])

                        present pair
                    end
                end
            end
        end
    end
end