# frozen_string_literal: true

module CodebreakerAi
  class AbstractValidator
    def initialize
      raise AbstractClassError, I18n.t(:"error.class.abstarct_class")
    end

    def valid(_value)
      raise AbstractMethodError, I18n.t(:"error.class.abstarct_method")
    end

    def message
      raise AbstractMethodError, I18n.t(:"error.class.abstarct_method")
    end
  end

  class NameValidator < AbstractValidator
    def initialize; end

    def valid(name)
      name.instance_of?(String) && name.length.between?(3, 20)
    end

    def message
      I18n.t(:"validator.invalid_name")
    end
  end

  class DifficultyValidator < AbstractValidator
    def initialize; end

    def valid(difficulty)
      DIFFICULTIES.include? difficulty.to_sym.downcase
    end

    def message
      I18n.t(:"validator.invalid_difficulty")
    end
  end

  class ConfirmationValidator < AbstractValidator
    CONFIRMATION = {
      y: 'y',
      yes: 'yes',
      n: 'n',
      no: 'no'
    }.freeze

    def initialize; end

    def valid(value)
      CONFIRMATION.include? value.to_sym.downcase
    end

    def message
      format('%<message>s %<title>s: %<values>s',
             message: I18n.t(:"validator.invalid_confirmation"),
             title: I18n.t(:allowed_values),
             values: self.CONFIRMATION.to_a.join(', '))
    end
  end

  class GuessValidator < AbstractValidator
    attr_reader :message

    def initialize; end

    def valid(value)
      @message = nil
      value = value.to_s
      if check_size(value)
        @message = format(I18n.t(:"validator.guess.length"), NUMBER_SIZE)
      elsif check_range(value)
        @message = format(I18n.t(:"validator.guess.range"), min, max)
      end

      @message.nil?
    end

    private

    def check_size(value)
      NUMBER_SIZE != value.length
    end

    def check_range(value)
      value_array = value.each_char.map(&:to_i)
      value_array.all? { |number| !number.between?(min, max) }
    end

    def min
      ALLOWED_NUMBERS.to_a.min
    end

    def max
      ALLOWED_NUMBERS.to_a.max
    end
  end
end
