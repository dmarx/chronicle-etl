module Chronicle
  module ETL
    # Abstract class representing an Transformer for an ETL job
    class Transformer
      extend Chronicle::ETL::Catalog

      # Construct a new instance of this transformer. Options are passed in from a Runner
      # == Paramters:
      # options::
      #   Options for configuring this Transformer
      def initialize(options = {})
        @options = options
      end

      # The main entrypoint for transforming a record. Called by a Runner on each extracted record
      def transform data
        raise NotImplementedError
      end

      # The domain or provider-specific id of the record this transformer is working on.
      # Used for building a cursor so an extractor doesn't have to start from the beginning of a
      # data source from the beginning.
      def id; end

      # The domain or provider-specific timestamp of the record this transformer is working on.
      # Used for building a cursor so an extractor doesn't have to start from the beginning of a
      # data source from the beginning.
      def timestamp; end
    end
  end
end

require_relative 'json_transformer'
require_relative 'null_transformer'
