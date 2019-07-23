# frozen_string_literal: true

module CodebreakerAi
  NUMBER_SIZE = 4
  ALLOWED_NUMBERS = (1..6).freeze

  FULLY_MATCH_SIGN = '+'
  PARTLY_MATCH_SIGN = '-'

  DIFFICULTIES = {
    easy: { attempts: 15, hints: 2 },
    medium: { attempts: 10, hints: 1 },
    hell: { attempts: 5, hints: 1 }
  }.freeze
end
