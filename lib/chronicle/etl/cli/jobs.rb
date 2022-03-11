require 'pp'
require 'tty-prompt'

module Chronicle
  module ETL
    module CLI
      # CLI commands for working with ETL jobs
      class Jobs < SubcommandBase
        default_task "start"
        namespace :jobs

        class_option :name, aliases: '-j', desc: 'Job configuration name'

        class_option :extractor, aliases: '-e', desc: "Extractor class. Default: stdin", banner: 'NAME'
        class_option :'extractor-opts', desc: 'Extractor options', type: :hash, default: {}
        class_option :transformer, aliases: '-t', desc: 'Transformer class. Default: null', banner: 'NAME'
        class_option :'transformer-opts', desc: 'Transformer options', type: :hash, default: {}
        class_option :loader, aliases: '-l', desc: 'Loader class. Default: table', banner: 'NAME'
        class_option :'loader-opts', desc: 'Loader options', type: :hash, default: {}

        # This is an array to deal with shell globbing
        class_option :input, aliases: '-i', desc: 'Input filename or directory', default: [], type: 'array', banner: 'FILENAME'
        class_option :since, desc: "Load records SINCE this date", banner: 'DATE'
        class_option :until, desc: "Load records UNTIL this date", banner: 'DATE'
        class_option :limit, desc: "Only extract the first LIMIT records", banner: 'N'

        class_option :output, aliases: '-o', desc: 'Output filename', type: 'string'
        class_option :fields, desc: 'Output only these fields', type: 'array', banner: 'field1 field2 ...'

        # Thor doesn't like `run` as a command name
        map run: :start
        desc "run", "Start a job"
        option :dry_run, desc: 'Only run the extraction and transform steps, not the loading', type: :boolean
        long_desc <<-LONG_DESC
          This will run an ETL job. Each job needs three parts:

            1. #{'Extractor'.underline}: pulls data from an external source. By default, this is stdout. Other common options including pulling data from an API or reading JSON from a file.

            2. #{'Transformer'.underline}: transforms data into a new format. If none is specified, we use the `null` transformer which does nothing to the data.

            3. #{'Loader'.underline}: takes that transformed data and loads it externally. This can be an API, flat files, (or by default), stdout. With the --dry-run option, this step won't be run.

            If you do not want to use the command line flags, you can also configure a job with a .yml config file. You can either specify the path to this file or use the filename and place the file in ~/.config/chronicle/etl/jobs/NAME.yml and call it with `--job NAME`
LONG_DESC
        # Run an ETL job
        def start
          run_job(options)
        rescue Chronicle::ETL::JobDefinitionError => e
          missing_plugins = e.job_definition.errors
            .select { |error| error.is_a?(Chronicle::ETL::PluginLoadError) }
            .map(&:name)
            .uniq

          install_missing_plugins(missing_plugins)
          run_job(options)
        end

        desc "create", "Create a job"
        # Create an ETL job
        def create
          job_definition = build_job_definition(options)
          job_definition.validate!

          path = File.join('chronicle', 'etl', 'jobs', options[:name])
          Chronicle::ETL::Config.write(path, job_definition.definition)
        rescue Chronicle::ETL::JobDefinitionError => e
          Chronicle::ETL::Logger.debug(e.full_message)
          Chronicle::ETL::Logger.fatal("Job definition error".red)
        end

        desc "show", "Show details about a job"
        # Show an ETL job
        def show
          job_definition = build_job_definition(options)
          job_definition.validate!
          puts Chronicle::ETL::Job.new(job_definition)
        rescue Chronicle::ETL::JobDefinitionError => e
          Chronicle::ETL::Logger.debug(e.full_message)
          Chronicle::ETL::Logger.fatal("Job definition error".red)
        end

        desc "list", "List all available jobs"
        # List available ETL jobs
        def list
          jobs = Chronicle::ETL::Config.available_jobs

          job_details = jobs.map do |job|
            r = Chronicle::ETL::Config.load("chronicle/etl/jobs/#{job}.yml")

            extractor = r[:extractor][:name] if r[:extractor]
            transformer = r[:transformer][:name] if r[:transformer]
            loader = r[:loader][:name] if r[:loader]

            [job, extractor, transformer, loader]
          end

          headers = ['name', 'extractor', 'transformer', 'loader'].map { |h| h.upcase.bold }

          puts "Available jobs:"
          table = TTY::Table.new(headers, job_details)
          puts table.render(indent: 0, padding: [0, 2])
        end

        private

        def run_job(options)
          job_definition = build_job_definition(options)
          job = Chronicle::ETL::Job.new(job_definition)
          runner = Chronicle::ETL::Runner.new(job)
          runner.run!
        end

        # TODO: probably could merge this with something in cli/plugin
        def install_missing_plugins(missing_plugins)
          prompt = TTY::Prompt.new
          message = "Plugin#{'s' if missing_plugins.count > 1} specified by job not installed.\n"
          message += "Do you want to install "
          message += missing_plugins.map { |name| "chronicle-#{name}".bold}.join(", ")
          message += " and start the job?"
          install = prompt.yes?(message)
          return unless install

          spinner = TTY::Spinner.new("[:spinner] Installing plugins...", format: :dots_2)
          spinner.auto_spin
          missing_plugins.each do |plugin|
            Chronicle::ETL::Registry::PluginRegistry.install(plugin)
          end
          spinner.success("(#{'successful'.green})")
        rescue Chronicle::ETL::PluginNotAvailableError => e
          spinner.error("Error".red)
          Chronicle::ETL::Logger.fatal("Plugin '#{e.name}' could not be installed".red)
        end

        # Create job definition by reading config file and then overwriting with flag options
        def build_job_definition(options)
          definition = Chronicle::ETL::JobDefinition.new
          definition.add_config(load_job_config(options[:name]))
          definition.add_config(process_flag_options(options).transform_keys(&:to_sym))
          definition
        end

        def load_job_config name
          Chronicle::ETL::Config.load_job_from_config(name)
        end

        # Takes flag options and turns them into a runner config
        def process_flag_options options
          extractor_options = options[:'extractor-opts'].merge({
            input: (options[:input] if options[:input].any?),
            since: options[:since],
            until: options[:until],
            limit: options[:limit],
          }.compact)

          transformer_options = options[:'transformer-opts']

          loader_options = options[:'loader-opts'].merge({
            output: options[:output],
            fields: options[:fields]
          }.compact)

          {
            dry_run: options[:dry_run],
            extractor: {
              name: options[:extractor],
              options: extractor_options
            }.compact,
            transformer: {
              name: options[:transformer],
              options: transformer_options
            }.compact,
            loader: {
              name: options[:loader],
              options: loader_options
            }.compact
          }
        end
      end
    end
  end
end
