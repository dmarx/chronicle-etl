## A CLI toolkit for extracting and working with your digital history

![chronicle-etl-banner](https://user-images.githubusercontent.com/6291/157330518-0f934c9a-9ec4-43d9-9cc2-12f156d09b37.png)

[![Gem Version](https://badge.fury.io/rb/chronicle-etl.svg)](https://badge.fury.io/rb/chronicle-etl) [![Ruby](https://github.com/chronicle-app/chronicle-etl/actions/workflows/ruby.yml/badge.svg)](https://github.com/chronicle-app/chronicle-etl/actions/workflows/ruby.yml)

Are you trying to archive your digital history or incorporate it into your own projects? You’ve probably discovered how frustrating it is to get machine-readable access to your own data. While [building a memex](https://hyfen.net/memex/), I learned first-hand what great efforts must be made before you can begin using the data in interesting ways.

If you don’t want to spend all your time writing scrapers, reverse-engineering APIs, or parsing takeout data, this project is for you! (*If you do enjoy these things, please see the [open issues](https://github.com/chronicle-app/chronicle-etl/issues).*)

**`chronicle-etl` is a CLI tool that gives you a unified interface for accessing your personal data.** It uses the ETL pattern to *extract* it from a source (e.g. your local browser history, a directory of images, goodreads.com reading history), *transform* it (into a given schema), and *load* it to a source (e.g. a CSV file, JSON, external API).

## What does `chronicle-etl` give you?
* **CLI tool for working with personal data**. You can monitor progress of exports, manipulate the output, set up recurring jobs, manage credentials, and more.
* **Plugins for many third-party providers**. A plugin system allows you to access data from third-party providers and hook it into the shared CLI infrastructure.
* **A common, opinionated schema**: You can normalize different datasets into a single schema so that, for example, all your iMessages and emails are stored in a common schema. Don’t want to use the schema? `chronicle-etl` always allows you to fall back on working with the raw extraction data.

## Installation
```sh
# Install chronicle-etl
gem install chronicle-etl
```

After installation, the `chronicle-etl` command will be available in your shell. Homebrew support [is coming soon](https://github.com/chronicle-app/chronicle-etl/issues/13).

## Basic usage and running jobs

```sh
# Display help
$ chronicle-etl help

# Basic job usage
$ chronicle-etl --extractor NAME --transformer NAME --loader NAME

# Read test.csv and display it to stdout as a table 
$ chronicle-etl --extractor csv --input ./data.csv --loader table
```

### Common options
```sh
Options:
  -j, [--name=NAME]                    # Job configuration name
  -e, [--extractor=EXTRACTOR-NAME]     # Extractor class. Default: stdin
      [--extractor-opts=key:value]     # Extractor options
  -t, [--transformer=TRANFORMER-NAME]  # Transformer class. Default: null
      [--transformer-opts=key:value]   # Transformer options
  -l, [--loader=LOADER-NAME]           # Loader class. Default: stdout
      [--loader-opts=key:value]        # Loader options
  -i, [--input=FILENAME]               # Input filename or directory
      [--since=DATE]                   # Load records SINCE this date. Overrides job's `load_since` configuration option in extractor's options
      [--until=DATE]                   # Load records UNTIL this date
      [--limit=N]                      # Only extract the first LIMIT records
  -o, [--output=OUTPUT]                # Output filename
      [--fields=field1 field2 ...]     # Output only these fields
      [--log-level=LOG_LEVEL]          # Log level (debug, info, warn, error, fatal)
                                       # Default: info
  -v, [--verbose], [--no-verbose]      # Set log level to verbose
      [--silent], [--no-silent]        # Silence all output
```

## Connectors
Connectors are available to read, process, and load data from different formats or external services.

```sh
# List all available connectors
$ chronicle-etl connectors:list
```

### Built-in Connectors
`chronicle-etl` comes with several built-in connectors for common formats and sources.

#### Extractors
- [`csv`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/extractors/csv_extractor.rb) - Load records from CSV files or stdin
- [`json`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/extractors/json_extractor.rb) - Load JSON (either [line-separated objects](https://en.wikipedia.org/wiki/JSON_streaming#Line-delimited_JSON) or one object)
- [`file`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/extractors/file_extractor.rb) - load from a single file or directory (with a glob pattern)

#### Transformers
- [`null`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/transformers/null_transformer.rb) - (default) Don’t do anything and pass on raw extraction data

#### Loaders
- [`table`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/loaders/table_loader.rb) - (default) Output an ascii table of records. Useful for exploring data.
- [`csv`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/extractors/csv_extractor.rb) - Load records to CSV
- [`json`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/loaders/json_loader.rb) - Load records serialized as JSON
- [`rest`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/loaders/rest_loader.rb) - Serialize records with [JSONAPI](https://jsonapi.org/) and send to a REST API

### Plugins
Plugins provide access to data from third-party platforms, services, or formats. 

```bash
# Install a plugin
$ chronicle-etl plugins:install NAME

# Install the imessage plugin
$ chronicle-etl plugins:install imessage

# List installed plugins
$ chronicle-etl plugins:list

# Uninstall a plugin
$ chronicle-etl plugins:uninstall NAME
```

A few dozen importers exist [in my Memex project](https://hyfen.net/memex/) and they’re being ported over to the Chronicle system. This table shows what’s available now and what’s coming. Rows are sorted in very rough order of priority.

If you want to work together on a connector, please [get in touch](#get-in-touch)!

| Name                                                            | Description                                                                                 | Availability                     |
|-----------------------------------------------------------------|---------------------------------------------------------------------------------------------|----------------------------------|
| [imessage](https://github.com/chronicle-app/chronicle-imessage) | iMessage messages and attachments                                                           | Available                        |
| [shell](https://github.com/chronicle-app/chronicle-shell)       | Shell command history                                                                       | Available (zsh support pending)  |
| [email](https://github.com/chronicle-app/chronicle-email)       | Emails and attachments from IMAP or .mbox files                                             | Available (imap support pending) |
| [pinboard](https://github.com/chronicle-app/chronicle-email)    | Bookmarks and tags                                                                          | Available                        |
| [safari](https://github.com/chronicle-app/chronicle-safari)     | Browser history from local sqlite db                                                        | Available                        |
| github                                                          | Github user and repo activity                                                               | In progress                      |
| chrome                                                          | Browser history from local sqlite db                                                        | Needs porting                    |
| whatsapp                                                        | Messaging history (via individual chat exports) or reverse-engineered local desktop install | Unstarted                        |
| anki                                                            | Studying and card creation history                                                          | Needs porting                    |
| facebook                                                        | Messaging and history posting via data export files                                         | Needs porting                    |
| twitter                                                         | History via API or export data files                                                        | Needs porting                    |
| foursquare                                                      | Location history via API                                                                    | Needs porting                    |
| goodreads                                                       | Reading history via export csv (RIP goodreads API)                                          | Needs porting                    |
| lastfm                                                          | Listening history via API                                                                   | Needs porting                    |
| images                                                          | Process image files                                                                         | Needs porting                    |
| arc                                                             | Location history from synced icloud backup files                                            | Needs porting                    |
| firefox                                                         | Browser history from local sqlite db                                                        | Needs porting                    |
| fitbit                                                          | Personal analytics via API                                                                  | Needs porting                    |
| git                                                             | Commit history on a repo                                                                    | Needs porting                    |
| google-calendar                                                 | Calendar events via API                                                                     | Needs porting                    |
| instagram                                                       | Posting and messaging history via export data                                               | Needs porting                    |
| shazam                                                          | Song tags via reverse-engineered API                                                        | Needs porting                    |
| slack                                                           | Messaging history via API                                                                   | Need rethinking                  |
| strava                                                          | Activity history via API                                                                    | Needs porting                    |
| things                                                          | Task activity via local sqlite db                                                           | Needs porting                    |
| bear                                                            | Note taking activity via local sqlite db                                                    | Needs porting                    |
| youtube                                                         | Video activity via takeout data and API                                                     | Needs porting                    |

### Writing your own connector

Additional connectors are packaged as separate ruby gems. You can view the [iMessage plugin](https://github.com/chronicle-app/chronicle-imessage) for an example.

If you want to load a custom connector without creating a gem, you can help by [completing this issue](https://github.com/chronicle-app/chronicle-etl/issues/23).

If you want to work together on a connector, please [get in touch](#get-in-touch)! 

#### Sample custom Extractor class
```ruby
module Chronicle
  module FooService
    class FooExtractor < Chronicle::ETL::Extractor
      register_connector do |r|
        r.identifier = 'foo'
        r.description = 'From foo.com'
      end

      setting :access_token, required: true

      def prepare
        @records = # load from somewhere
      end

      def extract
        @records.each do |record|
          yield Chronicle::ETL::Extraction.new(data: row.to_h)
        end
      end
    end
  end
end
```

## Development
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Additional development commands
```bash
# run tests
bundle exec rake spec

# generate docs
bundle exec rake yard

# use Guard to run specs automatically
bundle exec guard
```

## Get in touch
- [@hyfen](https://twitter.com/hyfen) on Twitter
- [@hyfen](https://github.com/hyfen) on Github
- Email: andrew@hyfen.net

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/chronicle-app/chronicle-etl. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct
Everyone interacting in the Chronicle::ETL project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/chronicle-app/chronicle-etl/blob/main/CODE_OF_CONDUCT.md).
