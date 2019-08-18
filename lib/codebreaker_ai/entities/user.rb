# frozen_string_literal: true

module CodebreakerAi
  class User
    attr_reader :name, :difficulty

    def initialize(name, difficulty)
      @name = name
      @difficulty = difficulty
    end
  end
end
