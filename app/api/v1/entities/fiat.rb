# encoding: UTF-8
# frozen_string_literal: true

module API
    module V1
      module Entities
        class Fiat < Base
          expose(
            :name,
            as: :name,
            documentation: {
              desc: 'Fiat Name.',
              type: String
            }
          )

          expose(
            :code,
            as: :code,
            documentation: {
              desc: 'Fiat Code.',
              type: String
            }
          )

          expose(
            :symbol,
            as: :symbol,
            documentation: {
              desc: 'Fiat Symbol.',
              type: String
            }
          )

          expose(
            :scale,
            as: :scale,
            documentation: {
              desc: 'Fiat Scale.',
              type: String
            }
          )

          expose(
            :icon_url,
            as: :icon,
            documentation: {
              desc: 'Fiat Flag Country.',
              type: String
            }
          )
        end
      end
    end
  end
  