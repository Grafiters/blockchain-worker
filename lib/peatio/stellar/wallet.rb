module Stellar
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

    def create_transaction!(transaction, options = {})
      account_address = normalize_address(@wallet[:address])
      destination_address = normalize_address(transaction.to_address)
      destination_tag = destination_tag_from(transaction.to_address)

      fee = calculate_current_fee
      amount = convert_to_base_unit(transaction.amount)

      # Subtract fees from initial deposit amount in case of deposit collection
      amount -= fee if options.dig(:subtract_fee)
      transaction.amount = convert_from_base_unit(amount) unless transaction.amount == amount

      return transaction if amount <= 0
      params = {
        privKey: @wallet.fetch(:secret),
        to: destination_address,
        amount: transaction.amount,
        memo: destination_tag.to_s
      }
      response = client.rest_api(:post, '/send-transaction', params)
      hash = response.fetch('hash')
      unless hash
        raise Stellar::Client::Error, \
              "Withdrawal from #{@wallet.fetch(:address)} to #{transaction.to_address} failed."
      end

      transaction.amount = amount
      transaction.hash = hash
      transaction.options = options
      transaction
    end


    # Returns fee in drops that is enough to process transaction in current ledger
    def calculate_current_fee
      client.rest_api(:get,'/get-fee').yield_self do |result|
        fee = result.to_d / 100000.to_d
        fee.to_d
      end
    end

    def latest_block_number
      client.rest_api(:get, '/get-height').fetch('height')
    rescue Stellar::Client::Error => e
      raise Peatio::Blockchain::ClientError, e
    end

    def load_balance!
      client.rest_api(:post, '/get-balance',{address: normalize_address(@wallet.fetch(:address))})
                      .fetch('balance')
                      .to_d
                      .yield_self { |amount| convert_from_base_unit(amount) }

    rescue Stellar::Client::Error => e
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
      value.to_d
    end

    def client
      uri = @wallet.fetch(:uri) { raise Peatio::Wallet::MissingSettingError, :uri }
      @client ||= Client.new(uri)
    end
  end
end
