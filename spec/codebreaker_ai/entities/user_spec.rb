# frozen_string_literal: true

module CodebreakerAi
  RSpec.describe User do
    let(:name) { 'Alex' }
    let(:difficulty) { 'easy' }

    context 'when #initialize' do
      let(:user) { described_class.new(name, difficulty) }

      it 'when check name' do
        expect(user.name).to eq(name)
      end

      it 'when check difficulty' do
        expect(user.difficulty).to eq(difficulty)
      end
    end
  end
end
