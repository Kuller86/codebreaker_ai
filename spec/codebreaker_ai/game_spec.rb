# frozen_string_literal: true

module CodebreakerAi
  RSpec.describe Game do
    let(:user) { CodebreakerAi::User.new('Test', 'easy') }
    let(:game) { described_class.new(user) }

    context 'when Tests for create and restore state game' do
      it 'when create state' do
        game.start
        game_state = game.create_state
        expect(game_state).instance_of?(CodebreakerAi::GameState)
      end

      context 'when restore state' do
        let(:state) do
          { secret_number: '1678', available_hints_indexes: [0, 1, 2], user: user,
            attempts_count: 12, hints_count: 1, show_hints: [1, 7], state: Game::STATES['progress'] }
        end
        let(:game_state) { GameState.new(state) }

        before do
          game.restore_state(game_state)
        end

        it 'check secret_number' do
          expect(game.instance_variable_get(:@secret_number)).to eq(game_state.secret_number)
        end

        it 'check available_hints_indexes' do
          expect(game.instance_variable_get(:@available_hints_indexes)).to eq(game_state.available_hints_indexes)
        end

        it 'check user' do
          expect(game.instance_variable_get(:@user)).to eq(game_state.user)
        end

        it 'check attempts_count' do
          expect(game.instance_variable_get(:@attempts_count)).to eq(game_state.attempts_count)
        end

        it 'check hints_count' do
          expect(game.instance_variable_get(:@hints_count)).to eq(game_state.hints_count)
        end

        it 'check show_hints' do
          expect(game.instance_variable_get(:@show_hints)).to eq(game_state.show_hints)
        end

        it 'check state' do
          expect(game.instance_variable_get(:@state)).to eq(game_state.state)
        end
      end
    end

    context 'when start' do
      it 'when secret code not empty' do
        game.start
        secret_number = game.instance_variable_get(:@secret_number)
        expect(secret_number).not_to be_empty
      end

      it 'when renew game' do
        game.start
        secret_number = game.instance_variable_get(:@secret_number)
        game.start
        secret_number_next = game.instance_variable_get(:@secret_number)

        expect(secret_number).not_to eq(secret_number_next)
      end
    end

    context 'when call match' do
      before do
        game.start
        game.instance_variable_set(:@secret_number, [1, 2, 3, 4])
      end

      it 'when 1 strict match' do
        result = game.match(1111)

        expect(result).to eq(strict_matches: 1, non_strict_matches: 0)
      end

      it 'when 2 strict match' do
        result = game.match(1212)

        expect(result).to eq(strict_matches: 2, non_strict_matches: 0)
      end

      it 'when 1 strict and 1 non strict matches' do
        result = game.match(1351)

        expect(result).to eq(strict_matches: 1, non_strict_matches: 1)
      end

      it 'when win' do
        expect { game.match(1234) }.to raise_error WinException
      end

      it 'when lose' do
        game.instance_variable_set(:@attempts_count, 1)
        expect { game.match(4321) }.to raise_error LoseException
      end
    end

    context 'when hint' do
      before do
        game.start
        game.instance_variable_set(:@secret_number, [1, 2, 3, 4])
      end

      it 'when get hint (define)' do
        allow(game).to receive(:hint_index).and_return(0)
        expect(game.hint).to eq(1)
      end

      it 'when get hint (random)' do
        expect(game.hint).to be_instance_of(Integer)
      end

      it 'when no hints left' do
        game.instance_variable_set(:@hints_count, 0)
        expect { game.hint }.to raise_error HintException
      end
    end

    context 'when methods *_used' do
      before do
        game.start
        state = { secret_number: '1678', available_hints_indexes: [1, 2, 3], user: user,
                  attempts_count: 12, hints_count: 1, show_hints: [1], state: Game::STATES['progress'] }
        game_state = CodebreakerAi::GameState.new(state)
        game.restore_state(game_state)
      end

      it 'when call attempts_used' do
        expect(game.attempts_used).to eq(3)
      end

      it 'when call hints_used' do
        expect(game.hints_used).to eq(1)
      end
    end

    context 'when tests statistics' do
      before do
        game.start
        state = { secret_number: '1678', available_hints_indexes: [1, 2, 3], user: user,
                  attempts_count: 12, hints_count: 1, show_hints: [1], state: Game::STATES['progress'] }
        game_state = GameState.new(state)
        game.restore_state(game_state)
      end

      it 'when call statistics' do
        expect(game.statistics).instance_of?(CodebreakerAi::Statistics)
      end
    end
  end
end
