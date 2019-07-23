# frozen_string_literal: true

module CodebreakerAi
  class CLI
    COMMANDS = {
      start: 'start',
      stats: 'stats',
      rules: 'rules',
      exit: 'exit',
      hint: 'hint',
      yes: 'y',
      no: 'n'
    }.freeze

    def self.close
      puts I18n.t(:good_bye)
      exit
    end

    def run
      puts I18n.t(:"welcome")
      menu
    end

    private

    def menu
      menu = [I18n.t(:"menu.start"), I18n.t(:"menu.stats"), I18n.t(:"menu.rules"), I18n.t(:"menu.exit")]
      loop do
        menu.map { |element| puts element.to_s }
        case gets.strip.downcase
        when COMMANDS[:start] then init_game
        when COMMANDS[:stats] then stats
        when COMMANDS[:rules] then rules
        when COMMANDS[:exit] then self.class.close
        else puts I18n.t(:wrong_command)
        end
      end
    end

    def rules
      clear_screen
      puts Game.rules
      puts_press_any_key
      STDIN.getch
      clear_screen
    end

    def stats
      clear_screen
      puts_press_any_key
      STDIN.getch
      clear_screen
    end

    def init_game
      name = sign
      difficulty = choose_difficulty
      @user = User.new(name, difficulty)
      puts "User: #{@user.name}, difficulty: #{@user.difficulty} "
      @game = Game.new(@user)
      @game.start
      play
    end

    def sign
      name_validator = NameValidator.new
      cli_input(label: I18n.t(:"sign.enter_your_name"), validator: name_validator)
    end

    def choose_difficulty
      difficulty_validator = DifficultyValidator.new
      cli_input(label: I18n.t(:"sign.choose_difficulty"), validator: difficulty_validator)
    end

    def cli_input(label:, validator:)
      loop do
        puts label
        input = gets.strip
        return input if [COMMANDS[:exit], COMMANDS[:hint]].include? input.downcase
        return input if validator.valid(input)

        puts validator.message
      end
    end

    def exit_command?(command)
      COMMANDS[:exit] == command.downcase
    end

    def hint_command?(command)
      COMMANDS[:hint] == command.downcase
    end
    #
    # def create_hint_command(game)
    #   raise ArgumentError unless game.instance_of? Game
    #
    #   Command.new('hint', proc do
    #     puts game.hint
    #                       rescue HintException => e
    #                         puts e.message
    #   end)
    # end

    def play
      loop do
        guess_validator = GuessValidator.new
        input = cli_input(label: I18n.t(:"game.your_guess"), validator: guess_validator)
        next if input.nil?

        case input.downcase
        when COMMANDS[:hint] then hint
        when COMMANDS[:exit] then self.class.close
        else match(input)
        end
      end
    rescue WinException => e; win(e)
    rescue LoseException => e; lose(e)
    rescue HintException => e; no_hint(e)
    end

    def hint
      puts @game.hint
    end

    def match(number)
      match = @game.match(number)
      result = ''
      match.inspect
      match[:strict_matches].to_i.times { result += '+' }
      match[:non_strict_matches].to_i.times { result += '-' }
      puts result
    end

    def win(exception)
      puts exception.message
      save_statistic
      start_new_game
    end

    def lose(exception)
      puts exception.message
      start_new_game
    end

    def no_hint(exception)
      puts exception.message
      play
    end

    def confirmation_save_statistic
      confirmation_validator = ConfirmationValidator.new
      cli_input(label: I18n.t(:do_you_want_to_save_your_result), validator: confirmation_validator)
    end

    def save_statistic
      confirmation = confirmation_save_statistic

      CodebreakerAi::StatisticsManager.save_data(@game.statistics) if %w[yes y].include?(confirmation)
    end

    def confirmation_start_new_game
      confirmation_validator = ConfirmationValidator.new
      cli_input(label: I18n.t(:do_you_want_to_start_new_game), validator: confirmation_validator)
    end

    def start_new_game
      confirmation = confirmation_start_new_game

      init_game if ConfirmationValidator::CONFIRMATION.include? confirmation.to_sym
    end

    def clear_screen
      Gem.win_platform? ? (system 'cls') : (system 'clear')
    end

    def puts_press_any_key
      puts ''
      puts I18n.t(:press_any_key)
    end
  end
end
