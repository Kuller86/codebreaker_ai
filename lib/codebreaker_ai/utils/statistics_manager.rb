# frozen_string_literal: true

module CodebreakerAi
  class StatisticsManager
    STORE_FILE = './storage_ai/statistics.yaml'

    def self.load_data(filename)
      YAML.safe_load(
        File.read(filename),
        [CodebreakerAi::Statistics, Date, Symbol],
        [],
        true
      )
    end

    def self.save_data(data, filename = STORE_FILE)
      File.new(filename, 'w+') unless File.exist?(filename)
      File.write(filename, YAML.dump(data), File.size(filename))
    end
  end
end
