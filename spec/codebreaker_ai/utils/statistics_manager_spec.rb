# frozen_string_literal: true

module CodebreakerAi
  RSpec.describe StatisticsManager do
    let(:filename) { File.expand_path('../../../storage_ai/statistics_test.yaml', __dir__) }
    let(:statistics) do
      CodebreakerAi::Statistics.new(name: 'Alex', difficulty: 'easy', attempts_used: 5,
                                    hints_used: 0, date: Date.new)
    end

    context 'when data save cases' do
      before do
        File.open(filename, 'w+')
      end

      it 'when if empty file' do
        described_class.save_data(statistics, filename)
        expect(File.size(filename)).not_to eq(0)
      end

      it 'when append in file' do
        filesize = File.size(filename)
        described_class.save_data(statistics, filename)
        expect(File.size(filename)).to be > filesize
      end
    end
  end
end
