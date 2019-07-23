# frozen_string_literal: true

module CodebreakerAi
  class GameState
    attr_reader :secret_number, :available_hints_indexes, :user, :attempts_count, :hints_count, :show_hints,
                :ready_to_play

    def initialize(state)
      @secret_number = state[:secret_number]
      @available_hints_indexes = state[:available_hints_indexes]
      @user = state[:user]
      @attempts_count = state[:attempts_count]
      @hints_count = state[:hints_count]
      @show_hints = state[:show_hints]
      @ready_to_play = state[:ready_to_play]
    end
  end

  class Game
    attr_reader :attempts_count, :hints_count, :show_hints

    class << self
      def rules
        path = File.expand_path('lib/codebreaker_ai/resources/rules') + "/#{I18n.locale}.txt"
        raise format('%<trans>s (%<path>s)', trans: I18n.t(:"error.file_not_found"), path: path) unless File.exist? path

        IO.read(path)
      end
    end

    # @param [CodebreakerAi::User] user
    def initialize(user)
      @user = user
      @difficulty = user.difficulty.to_sym

      @attempts_count = DIFFICULTIES[@difficulty][:attempts]
      @hints_count = DIFFICULTIES[@difficulty][:hints]
      @show_hints = []
      @ready_to_play = false
    end

    def create_state
      state = {
        secret_number: @secret_number, available_hints_indexes: @available_hints_indexes, user: @user,
        attempts_count: @attempts_count,
        hints_count: @hints_count,
        show_hints: @show_hints,
        ready_to_play: @ready_to_play
      }
      CodebreakerAi::GameState.new(state)
    end

    # @param [CodebreakerAi::GameState] game_state
    def restore_state(game_state)
      @secret_number = game_state.secret_number
      @available_hints_indexes = game_state.available_hints_indexes
      @user = game_state.user
      @attempts_count = game_state.attempts_count
      @hints_count = game_state.hints_count
      @show_hints = game_state.show_hints
      @ready_to_play = game_state.ready_to_play
    end

    def start
      @secret_number = generate_secret_number
      @available_hints_indexes = (0...NUMBER_SIZE).to_a
      @ready_to_play = true
    end

    def match(input_number)
      raise BrokenGameException, I18n.t(:"error.game_wasnt_initialized") unless @ready_to_play

      result = SecretNumberResolver.resolve(secret_number: @secret_number, input_number: input_number)
      @attempts_count -= 1
      win?(result[:strict_matches])
      lose?
      result
    end

    def hint
      raise HintException, I18n.t(:"hint.no_hints_left") if @hints_count < 1

      @hints_count -= 1
      index = hint_index

      @show_hints << @secret_number[index]
      @secret_number[index]
    end

    def hints_left
      format('%<used>s/%<total>s',
             used: DIFFICULTIES[@difficulty][:hints] - @hints_count,
             total: DIFFICULTIES[@difficulty][:hints])
    end

    def attempts_left
      format('%<used>s/%<total>s',
             used: DIFFICULTIES[@difficulty][:attempts] - @attempts_count,
             total: DIFFICULTIES[@difficulty][:attempts])
    end

    def win?(strict_matches)
      raise WinException, I18n.t(:win) if NUMBER_SIZE == strict_matches.to_i
    end

    def lose?
      raise LoseException, I18n.t(:lose) if @attempts_count < 1
    end

    def statistics
      CodebreakerAi::Statistics.new(name: @user.name, difficulty: @user.difficulty, attempts_left: attempts_left,
                     hints_left: hints_left, date: Date.new)
    end

    private

    def generate_secret_number
      ALLOWED_NUMBERS.to_a.sample(NUMBER_SIZE)
    end

    def hint_index
      @available_hints_indexes.delete_at(@available_hints_indexes.sample)
    end
  end
end
