# frozen_string_literal: true

module CodebreakerAi
  class GameState
    attr_reader :secret_number, :available_hints, :user, :attempts_count, :hints_count, :show_hints,
                :state

    def initialize(state)
      @secret_number = state[:secret_number]
      @available_hints = state[:available_hints]
      @user = state[:user]
      @attempts_count = state[:attempts_count]
      @hints_count = state[:hints_count]
      @show_hints = state[:show_hints]
      @state = state[:state]
    end
  end

  class Game
    attr_reader :attempts_count, :hints_count, :show_hints
    STATES = { not_started: 0, progress: 1, win: 2, lose: 3 }.freeze

    NUMBER_SIZE = 4
    ALLOWED_NUMBERS = (1..6).freeze

    FULLY_MATCH_SIGN = '+'
    PARTLY_MATCH_SIGN = '-'

    DIFFICULTIES = {
      easy: { attempts: 15, hints: 2 },
      medium: { attempts: 10, hints: 1 },
      hell: { attempts: 5, hints: 1 }
    }.freeze

    # @param [CodebreakerAi::User] user
    def initialize(user)
      @user = user
      @difficulty = user.difficulty.to_sym

      @attempts_count = DIFFICULTIES[@difficulty][:attempts]
      @hints_count = DIFFICULTIES[@difficulty][:hints]
      @show_hints = []
      @state = STATES[:not_started]
    end

    def create_state
      state = {
        secret_number: @secret_number, available_hints: @available_hints, user: @user,
        attempts_count: @attempts_count,
        hints_count: @hints_count,
        show_hints: @show_hints,
        state: @state
      }
      CodebreakerAi::GameState.new(state)
    end

    # @param [CodebreakerAi::GameState] game_state
    def restore_state(game_state)
      @secret_number = game_state.secret_number
      @available_hints = game_state.available_hints
      @user = game_state.user
      @attempts_count = game_state.attempts_count
      @hints_count = game_state.hints_count
      @show_hints = game_state.show_hints
      @state = game_state.state
    end

    def start
      @secret_number = generate_secret_number
      @available_hints = @secret_number.clone.shuffle
      @state = STATES[:progress]
    end

    def match(input_number)
      raise EndGameException if @state > STATES[:progress]

      result = SecretNumberResolver.resolve(secret_number: @secret_number, input_number: input_number)
      @attempts_count -= 1
      recalculate_state(result)
      raise WinException, I18n.t('win') if win?
      raise LoseException, I18n.t('lose') if lose?

      result
    end

    def hint
      raise EndGameException, I18n.t('error.game_end') if @state > STATES[:progress]
      raise HintException, I18n.t('hint.no_hints_left') if @hints_count.zero?

      @hints_count -= 1
      value = @available_hints.pop
      @show_hints << value
      value
    end

    def hints_used
      DIFFICULTIES[@difficulty][:hints] - @hints_count
    end

    def attempts_used
      DIFFICULTIES[@difficulty][:attempts] - @attempts_count
    end

    def win?
      @state == STATES[:win]
    end

    def lose?
      @state == STATES[:lose]
    end

    def statistics
      CodebreakerAi::Statistics.new(name: @user.name, difficulty: @user.difficulty, attempts_used: attempts_used,
                                    hints_used: hints_used, date: Date.new)
    end

    private

    def recalculate_state(match_result)
      @state = STATES[:lose] if @attempts_count.zero?
      @state = STATES[:win] if NUMBER_SIZE == match_result[:strict_matches].to_i
    end

    def generate_secret_number
      ALLOWED_NUMBERS.to_a.sample(NUMBER_SIZE)
    end
  end
end
