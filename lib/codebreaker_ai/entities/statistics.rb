# frozen_string_literal: true

module CodebreakerAi
  class Statistics
    attr_reader :name, :difficulty, :attempts_used, :hints_used, :date

    def initialize(name:, difficulty:, attempts_used:, hints_used:, date:)
      @name = name
      @difficulty = difficulty
      @attempts_used = attempts_used
      @hints_used = hints_used
      @date = date
    end

    def attempts_left
      "#{@hints_used}/#{CodebreakerAi::DIFFICULTIES[@difficulty][:attempts]}"
    end

    def hints_left
      "#{@hints_used}/#{CodebreakerAi::DIFFICULTIES[@difficulty][:hints]}"
    end
  end
end
