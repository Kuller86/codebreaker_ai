# frozen_string_literal: true

module CodebreakerAi
  class AbstractError < RuntimeError
  end

  class AbstractClassError < AbstractError
  end

  class AbstractMethodError < AbstractError
  end

  class HintException < RuntimeError
  end

  class EndGameException < RuntimeError
  end

  class WinException < EndGameException
  end

  class LoseException < EndGameException
  end

  class BrokenGameException < RuntimeError
  end
end
