class EstimationService
  def initialize(params)
    @source = params[:source]
    @reference = params[:reference]
    @reward_data = params[:reward]
    @reward = 0.0
    @optional_reward = 0.0
    @market = []
  end

  def reward_result
    reward_currencies_data

    return @reward
  end

  private

  def reward_currencies_data
    @reward_data.each do |reward|
      if reward[:currency] == reward_currencies[:value]
        trade_data = trade(reward[:reference_id])
        @reward += trade_data[:price] * reward[:amount]
      else
        market_data = check_market(reward[:currency])
        next if !market_data
      end
    end
  end

  def market(trade_market_id)
    market = Market.where(id: trade_market_id)
    datas = market.each_with_object([]) do |mark, result|
        next if mark[:quote_unit] != reward_currencies[:value]
        result << mark[:id]
    end

    return datas
  end

  def check_market(base)
    Market.find_by(base_unit: base, quote_unit: reward_currencies[:value])
  end

  def trade(id)
    Trade.find_by(id: id)
  end

  def trade_list
    trade_data = Trade.where(id: @source)
    return trade_data.count > 0 ? trade_data : nil
  end

  def reward_currencies
    Setting.find_by(name: 'reward_currencies')
  end
end