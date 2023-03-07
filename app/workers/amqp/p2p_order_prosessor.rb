# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module AMQP
    class P2pOrderProcessor < Base
      def initialize
        ::P2pOrder.where(state: 'prepare').find_each do |order|
          ::P2pOrder.submit(order.id)
        rescue StandardError => e
          ::AMQP::Queue.enqueue(:trade_error, e.message)
          report_exception_to_screen(e)

          raise e if is_db_connection_error?(e)
        end
      end

      def process(payload)
        case payload['action']
        when 'submit'
          ::P2pOrder.submit(payload.dig('order', 'id'))
        when 'cancel'
          ::P2pOrder.cancel(payload.dig('order', 'id'))
        end
      rescue StandardError => e
        ::AMQP::Queue.enqueue(:trade_error, e.message)
        report_exception_to_screen(e)

        raise e if is_db_connection_error?(e)
      end
    end
  end
end
