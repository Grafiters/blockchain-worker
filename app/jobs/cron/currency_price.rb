module Jobs
  module Cron
    class CurrencyPrice
      class <<self
        def process
          Currency.coins.active.find_each do |currency|
            Currency.active.find_each do |pair|
              currency.update_price(pair)
            end
          rescue StandardError => e
            report_exception_to_screen(e)
            next
          end

          sleep 10
        end
      end
    end
  end
end
