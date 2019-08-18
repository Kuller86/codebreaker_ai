# frozen_string_literal: true

module CodebreakerAi
  class SecretNumberResolver
    def self.resolve(secret_number:, input_number:)
      instance = new(secret_number: secret_number.clone)
      instance.resolve(input_number)
    end

    def resolve(input_number)
      input_number_array = prepare_number(input_number).map(&:to_i)

      @secret_number.zip(input_number_array).map do |secret_number, user_number|
        next increase_strict_matches(user_number) if secret_number == user_number

        increase_non_strict_matches(user_number) if @secret_number.include? user_number
      end

      { strict_matches: @strict_matches, non_strict_matches: @non_strict_matches }
    end

    private

    def initialize(secret_number:)
      @secret_number = secret_number
      @strict_matches = 0
      @non_strict_matches = 0
    end

    def prepare_number(input_number)
      input_number.to_s.each_char
    end

    def increase_strict_matches(input_number)
      @strict_matches += 1
      delete_matched_number(input_number)
    end

    def increase_non_strict_matches(input_number)
      @non_strict_matches += 1
      delete_matched_number(input_number)
    end

    def delete_matched_number(input_number)
      index = @secret_number.index(input_number)
      @secret_number.delete_at(index) unless index.nil?
    end
  end
end
