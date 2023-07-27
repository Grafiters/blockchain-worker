# encoding: UTF-8
# frozen_string_literal: true

module Workers
    module AMQP
      class PayerFee < Base  
        def process(payload)
          case payload['action']
          when 'collect'
            process_collect(payload['order'])
          end

        rescue StandardError => e
          Rails.logger.warn {"================== Warning Error Collected Payer Fee ===================="}
          Rails.logger.warn e.inspect
        end

        def process_collect(id)
            wallet = Wallet.find_by(id: id)

            deposit = deposit_wallet(wallet.blockchain_key)

            address = PaymentAddress.where(blockchain_key: wallet.blockchain_key, address: deposit)

            balance = check_all_balance(wallet, address)

            record = Array.new

            balance.each do |process|
              record.push(WalletService.new(wallet).collect_payer_fee!(process))
            end

            Rails.logger.warn {"============= Payer Fee Status Before =============="}
            Rails.logger.warn Rails.cache.read("process_collect_#{wallet.id}")

            wallet.disable_status_payer_fee

            Rails.logger.warn {"============= Payer Fee Status After =============="}
            Rails.cache.write("process_collect_#{wallet.id}", 'false')
            Rails.logger.warn Rails.cache.read("process_collect_#{wallet.id}")

            Rails.logger.warn record.as_json
        end

        def check_all_balance(wallet, address)
            balance = WalletService.new(wallet).load_balance_user!(address)
            
            balance
        end

        def deposit_wallet(blockchain_key)
            deposit = Deposit.where(blockchain_key: blockchain_key).group(:address).pluck(:address)

            deposit
        end
      end
    end
end