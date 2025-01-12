require 'csv'

module Chronicle
  module ETL
    class CSVLoader < Chronicle::ETL::Loader
      include Chronicle::ETL::Loaders::Helpers::StdoutHelper

      register_connector do |r|
        r.description = 'CSV'
      end

      setting :output
      setting :headers, default: true
      setting :header_row, default: true

      def records
        @records ||= []
      end

      def load(record)
        records << record.to_h_flattened
      end

      def finish
        return unless records.any?

        headers = build_headers(records)

        csv_options = {}
        if @config.headers
          csv_options[:write_headers] = @config.header_row
          csv_options[:headers] = headers
        end

        csv_output = CSV.generate(**csv_options) do |csv|
          records.each do |record|
            csv << record
              .transform_keys(&:to_sym)
              .values_at(*headers)
              .map { |value| force_utf8(value) }
          end
        end

        # TODO: just write to io directly
        if output_to_stdout?
          write_to_stdout(csv_output)
        else
          File.write(@config.output, csv_output)
        end
      end
    end
  end
end
