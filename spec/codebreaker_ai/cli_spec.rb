# frozen_string_literal: true

module CodebreakerAi
  RSpec.describe CLI do
    let(:app) { described_class.new }
    let(:username) { 'username' }
    let(:difficulty) { 'easy' }
    let(:user) { User.new(username, difficulty) }

    before do
      allow(STDOUT).to receive(:puts).with(anything)
      allow(STDOUT).to receive(:print).with(anything)
      allow(app).to receive(:clear_screen)

      allow(app).to receive(:loop).and_yield
    end

    it 'when closes' do
      expect(STDOUT).to receive(:puts).with(I18n.t(:good_bye))
      expect(described_class).to receive(:exit)
      described_class.close
    end

    context 'when #console game' do
      after do
        app.run
      end

      it 'when main menu' do
        allow(app).to receive(:loop)

        expect(app).to receive(:menu)
        expect(STDOUT).to receive(:puts).with(I18n.t(:welcome))
      end

      xit 'when start' do
        allow(app).to receive_message_chain(:gets, :gets, :gets).and_return(['start', username, difficulty])
        # allow(app).to receive(:gets).and_return(username)
        # allow(app).to receive(:gets).and_return(difficulty)

        expect(app).to receive(:puts).with(I18n.t(:'game.your_guess'))
        # expect(STDOUT).to receive(:puts).with(I18n.t(:'sign.enter_your_name'))
      end
    end
  end
end
