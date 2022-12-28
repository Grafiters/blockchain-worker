# frozen_string_literal: true

RSpec.describe Peatio::Upstream::Nusadax do
  let(:upstream_nusadax_config) do
    {
      "driver": 'nusadax',
      "source": 'btcusd',
      "target": 'btcusd',
      "rest": 'http://localhost',
      "websocket": 'wss://localhost'
    }.stringify_keys
  end

  let(:nusadax) { Peatio::Upstream::Nusadax.new(upstream_nusadax_config) }

  let(:msg) do
    {
      'btcusd.trades' =>
      { 'trades' =>
        [{ 'tid' => 247_646_537,
           'taker_type' => 'buy',
           'date' => 1_584_437_804,
           'price' => '5194.0',
           'amount' => '0.01710500' }] }
    }
  end

  let(:subscribe_msg) do
    {
      'success' =>
      { 'message' => 'subscribed',
        'streams' => ['btcusd.trades'] }
    }
  end

  let(:trade) do
    {
      tid: 247_646_537,
      amount: '0.01710500',
      price: '5194.0',
      date: 1_584_437_804,
      taker_type: 'buy'
    }.stringify_keys
  end

  it 'detects trade' do
    nusadax.expects(:notify_public_trade).with(trade)
    nusadax.ws_read_public_message(msg)
  end

  it 'doesnt notify about public trade' do
    nusadax.expects(:notify_public_trade).never
    nusadax.ws_read_public_message(subscribe_msg)
  end
end
