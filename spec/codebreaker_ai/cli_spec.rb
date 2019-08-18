# frozen_string_literal: true

module CodebreakerAi
  RSpec.describe CLI do
    let(:output) { CodebreakerAi::CLIOutput.new }
    let(:input) { CodebreakerAi::CLIInput.new(output) }
    let(:app) { described_class.new(input, output) }
    let(:username) { 'username' }
    let(:difficulty) { 'easy' }
    let(:user) { User.new(username, difficulty) }

    before do
      allow(STDOUT).to receive(:puts).with(anything)
      allow(app).to receive(:loop).and_yield
    end

    context 'when #console game' do
      after do
        app.run
      end

      it 'when main menu' do
        expect(app).to receive(:menu)
      end

      it 'when rules' do
        allow(input).to receive(:gets).and_return('rules')
        expect(STDIN).to receive(:getch)
      end

      it 'when stats' do
        allow(input).to receive(:gets).and_return('stats')
        expect(STDIN).to receive(:getch)
      end

      it 'when play' do
        allow(input).to receive(:gets).and_return('start', username, difficulty)
        expect(app).to receive(:play)
      end

      it 'when hint' do
        allow(input).to receive(:gets).and_return('start', username, difficulty, 'hint')
        expect(app).to receive(:hint)
      end

      it 'when match' do
        allow(input).to receive(:gets).and_return('start', username, difficulty, '1234')
        expect(app).to receive(:match)
      end

      context 'when End Game' do
        before do
          allow(input).to receive(:gets).and_return('start', username, difficulty, '1234')
          allow(app).to receive(:guess).and_raise(CodebreakerAi::WinException)
        end

        it 'when start new game' do
          expect(app).to receive(:start_new_game)
        end
      end
    end
  end
end
