require 'csv'

module Chronicle
  module ETL
    class CsvLoader < Chronicle::ETL::Loader
      def initialize(options={})
        super(options)
        @rows = []
      end

      def load(result)
        if (result.is_a? Hash)
          @rows << result.values
        else
          @rows << result
        end
      end

      def finish
        z = $stdout
        CSV(z) do |csv|
          @rows.each do |row|
            csv << row
          end
        end
      end
    end
  end
end
