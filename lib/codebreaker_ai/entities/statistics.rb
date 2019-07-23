# frozen_string_literal: true

module CodebreakerAi
  class Statistics
    attr_reader :name, :difficulty, :attempts_left, :hints_left, :date

    def initialize(name:, difficulty:, attempts_left:, hints_left:, date:)
      @name = name
      @difficulty = difficulty
      @attempts_left = attempts_left
      @hints_left = hints_left
      @date = date
    end
  end
end
