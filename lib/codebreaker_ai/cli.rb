# frozen_string_literal: true

module CodebreakerAi
  class HintEvent
    def update(cli, input)
      puts 'hint called' + input
      cli.need_hint = true if input.casecmp('hint').zero?
    end
  end

  class ExitEvent
    def update(cli, input)
      puts 'run ExitEvent'
      cli.close_cli if input.casecmp('exit').zero?
    end
  end

  class CLIOutput
    def menu
      menu = [I18n.t('menu.start'), I18n.t('menu.stats'), I18n.t('menu.rules'), I18n.t('menu.exit')]
      menu.map { |element| puts element.to_s }
    end

    def label(label)
      puts label
    end

    def puts_press_any_key(label = nil)
      clear_screen
      puts label if label
      puts ''
      label(I18n.t('press_any_key'))
      STDIN.getch
      clear_screen
    end

    def match(match)
      result = ''
      match[:strict_matches].to_i.times { result += '+' }
      match[:non_strict_matches].to_i.times { result += '-' }
      puts result
    end

    private

    def clear_screen
      Gem.win_platform? ? (system 'cls') : (system 'clear')
    end
  end

  class CLIInput
    attr_writer :cli
    # @param [CodebreakerAi::CLIOutput] output
    def initialize(output)
      @output = output
      @cli = nil
    end

    def input_from_cli(label = nil)
      @output.label(label) if label
      input = gets.strip
      @cli.changed
      @cli.notify_observers(@cli, input)
      input
    end

    def input_validate(input, validator, callback, *args)
      unless validator.valid(input)
        puts validator.message
        input = args.empty? ? send(callback) : send(callback, args)
      end
      input
    end

    def registration
      input = input_from_cli(I18n.t('registration.enter_your_name'))
      input_validate(input, NameValidator.new, 'registration')
    end

    def choose_difficulty
      input = input_from_cli(I18n.t('registration.choose_difficulty'))
      input_validate(input, DifficultyValidator.new, 'choose_difficulty')
    end

    def confirmation(label)
      input = input_from_cli(label)
      input_validate(input, ConfirmationValidator.new, 'confirmation', label)
    end
  end

  class CLI
    attr_accessor :need_hint

    include Observable

    COMMANDS = { start: 'init_game', stats: 'stats', rules: 'rules',
                 exit: 'close_cli', hint: 'hint', yes: 'y', no: 'n' }.freeze

    # @param [CodebreakerAi::CLIInput] input
    # @param [CodebreakerAi::CLIOutput] output
    def initialize(input, output)
      @input = input
      @output = output
      @need_hint = false
    end

    def close_cli
      @output.label(I18n.t('good_bye'))
      exit
    end

    def run
      @input.cli = self
      add_observer(ExitEvent.new)
      @output.label(I18n.t('welcome'))
      loop { menu }
    end

    private

    def menu
      @output.menu
      input = @input.input_from_cli.downcase
      if COMMANDS.key?(input.to_sym)
        send(COMMANDS[input.to_sym])
      else
        @output.label(I18n.t('wrong_command'))
      end
    end

    def rules
      @output.puts_press_any_key(I18n.t('rules'))
    end

    def stats
      @output.puts_press_any_key(nil)
    end

    def init_game
      @user = User.new(registration, choose_difficulty)
      @game = Game.new(@user)
      @game.start
      play
    end

    def registration
      @input.registration
    end

    def choose_difficulty
      @input.choose_difficulty
    end

    def play
      hint_event = HintEvent.new
      add_observer(hint_event)
      loop { guess }
    rescue EndGameException
      delete_observer(hint_event)
      end_game
    end

    def guess
      validator = GuessValidator.new
      input = @input.input_from_cli(I18n.t('game.your_guess'))
      return hint if @need_hint

      unless validator.valid(input)
        @output.label(validator.message)
        return
      end

      match(input)
    end

    def hint
      begin
        result = @game.hint
      rescue HintException => e
        result = e.message
      end
      @need_hint = false
      @output.label(result)
    end

    def match(number)
      match = @game.match(number)
      @output.match(match)
    end

    def end_game
      if @game.win?
        @output.label(I18n.t('win'))
        save_statistic
      else
        @output.label(I18n.t('lose'))
      end
      start_new_game
    end

    def confirmation(label)
      @input.confirmation(label)
    end

    def save_statistic
      confirmation = confirmation(I18n.t('do_you_want_to_save_your_result'))
      CodebreakerAi::StatisticsManager.save_data(@game.statistics) if %w[yes y].include?(confirmation)
    end

    def start_new_game
      confirmation = confirmation(I18n.t('do_you_want_to_start_new_game'))
      init_game if %w[yes y].include?(confirmation)
    end
  end
end
