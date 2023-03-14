module Ripple
  class Wallet < Peatio::Wallet::Abstract

    Error = Class.new(StandardError)

    DEFAULT_FEATURES = { skip_deposit_collection: false }.freeze

    def initialize(custom_features = {})
      @features = DEFAULT_FEATURES.merge(custom_features).slice(*SUPPORTED_FEATURES)
      @settings = {}
    end

    def configure(settings = {})
      # Clean client state during configure.
      @client = nil
      @settings.merge!(settings.slice(*SUPPORTED_SETTINGS))

      @wallet = @settings.fetch(:wallet) do
        raise Peatio::Wallet::MissingSettingError, :wallet
      end.slice(:uri, :address, :secret)

      @currency = @settings.fetch(:currency) do
        raise Peatio::Wallet::MissingSettingError, :currency
      end.slice(:id, :base_factor, :options)
    end

    def create_address!(_setting)
      {
        address: "#{@wallet[:address]}?dt=#{SecureRandom.random_number(10**6)}",
        secret: @wallet[:secret]
      }
    end

    def create_raw_address(options = {})
      secret = options.fetch(:secret) { PasswordGenerator.generate(64) }
      result = client.rest_api(:post,'/wallet_propose', { passphrase: secret })

      result.slice('key_type', 'master_seed', 'master_seed_hex',
                    'master_key', 'public_key', 'public_key_hex')
            .merge(address: normalize_address(result.fetch('account_id')), secret: secret)
            .symbolize_keys
    end

    def create_transaction!(transaction, options = {})
      tx_blob = sign_transaction(transaction, options)
      client.rest_api(:post,'/submit', tx_blob).yield_self do |result|
        error_message = {
          message: result.fetch('engine_result_message'),
          status: result.fetch('engine_result')
        }

        # TODO: It returns provision results. Transaction may fail or success
        # than change status to opposite one before ledger is final.
        # Need to set special status and recheck this transaction status
        if result['engine_result'].to_s == 'tesSUCCESS' && result['status'].to_s == 'success'
          transaction.currency_id = 'xrp' if transaction.currency_id.blank?
          transaction.hash = result.fetch('tx_json').fetch('hash')
        else
          raise Error, "XRP withdrawal from #{@wallet.fetch(:address)} to #{transaction.to_address} failed. Message: #{error_message}."
        end
        transaction
      end
    end

    def sign_transaction(transaction, options = {})
      account_address = normalize_address(@wallet[:address])
      destination_address = normalize_address(transaction.to_address)
      destination_tag = destination_tag_from(transaction.to_address)
      fee = calculate_current_fee

      account = client.rest_api(:post, '/account_info',{method: "account_info", params: [{account: account_address, ledger_index: 'validated', strict: true}]}).dig('result')
      sequence = account.fetch('account_data').fetch('Sequence')
      amount = convert_to_base_unit(transaction.amount)

      # Subtract fees from initial deposit amount in case of deposit collection
      amount -= fee if options.dig(:subtract_fee)
      transaction.amount = convert_from_base_unit(amount) unless transaction.amount == amount

        params = {
        secret: @wallet.fetch(:secret),
        tx_json: {
          Account:            account_address,
          Amount:             amount.to_s,
          Fee:                fee.to_s,
          Destination:        destination_address,
          DestinationTag:     destination_tag,
          TransactionType:    'Payment',
          LastLedgerSequence: latest_block_number + 4,
          Sequence: sequence
          }
        }

        Rails.logger.warn params

      client.rest_api(:post,'/sign', {method: 'sign', params: [params]}).dig('result').yield_self do |result|
        if result['status'].to_s == 'success'
          { tx_blob: result['tx_blob'] }
        else
          raise Error, "XRP sign transaction from #{account_address} to #{destination_address} failed: #{result}."
        end
      end
    end

    # Returns fee in drops that is enough to process transaction in current ledger
    def calculate_current_fee
      client.rest_api(:post,'/fee', {method: "fee"}).dig('result').yield_self do |result|
        result.dig('drops', 'open_ledger_fee').to_i
      end
    end

    def latest_block_number
      client.rest_api(:post,'/ledger', { method:'ledger', params: [{ledger_index: 'validated'}] }).dig('result').fetch('ledger_index')
    rescue Ripple::Client::Error => e
      raise Peatio::Blockchain::ClientError, e
    end

    def load_balance!
      client.rest_api(:post, '/account_info',
                      {account: normalize_address(@wallet.fetch(:address)), ledger_index: 'validated', strict: true})
                      .fetch('account_data')
                      .fetch('Balance')
                      .to_d
                      .yield_self { |amount| convert_from_base_unit(amount) }

    rescue Ripple::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    private

    def destination_tag_from(address)
      address =~ /\?dt=(\d*)\Z/
      $1.to_i
    end

    def normalize_address(address)
      address.gsub(/\?dt=\d*\Z/, '')
    end

    def convert_from_base_unit(value)
      value.to_d / @currency.fetch(:base_factor).to_d
    end

    def convert_to_base_unit(value)
      x = value.to_d * @currency.fetch(:base_factor)
      unless (x % 1).zero?
        raise Peatio::Ripple::Wallet::Error,
            "Failed to convert value to base (smallest) unit because it exceeds the maximum precision: " \
            "#{value.to_d} - #{x.to_d} must be equal to zero."
      end
      x.to_i
    end

    def client
      uri = @wallet.fetch(:uri) { raise Peatio::Wallet::MissingSettingError, :uri }
      @client ||= Client.new(uri)
    end
  end
end
