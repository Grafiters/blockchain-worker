# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class Version < Base
        expose(:build_date,
               format_with: :iso8601,
               documentation: {
                 type: String,
                 desc: 'Running Exchange build date in iso8601 format'
               }
        )
      end
    end
  end
end
