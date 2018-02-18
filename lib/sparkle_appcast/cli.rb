require "rubygems"
require "thor"
require "kramdown"
require "time"

module SparkleAppcast
  class Cli < Thor
    def self.exit_on_failure?
      true
    end

    desc "appcast FILE", "Create `appcast.xml` with an application archive file."
    long_desc <<-END_OF_DESCRIPTION
      Create `appcast.xml` with an application archive file.
      The application archive file must contain exact one application bundle.
    END_OF_DESCRIPTION
    option :key, type: :string, required: true, desc: "Path to a DSA private key."
    option :url, type: :string, required: true, desc: "URL to the application archive file published."
    option :release_note, type: :string, required: true, desc: "Path to a release note text file in Markdown format."
    option :output, type: :string, desc: "Path to an output `appcast.xml`."
    option :title, type: :string, desc: "Title for the release note."
    option :publish_date, type: :string, desc: "Publish date time in local timezone."
    option :channel_title, type: :string, default: "Change log", desc: "Title of the channel."
    option :channel_description, type: :string, default: "The most recent changes.", desc: "Description of the channel."
    def appcast(file)
      params = {
        channel_title: options[:channel_title],
        channel_description: options[:channel_description]
      }
      params[:title] = options[:title] if options[:title]
      params[:publish_date] = Time.parse(options[:publish_date]) if options[:publish_date]

      appcast = Appcast.new(
        Archive.new(file),
        Signer.new(options[:key]),
        options[:url],
        ReleaseNote.new(options[:release_note]),
        params
      )

      rss = appcast.rss.to_s
      if options[:output]
        File.open(options[:output], "w") do |output|
          output.puts(rss)
        end
      else
        STDOUT.puts(rss)
      end
    end

    desc "info FILE", "Print information about the application bundle."
    Bundle::INFO_KEYS.each do |key|
      option key, type: :boolean, desc: "Print #{key}."
    end
    def info(file)
      bundle_info = if File.file?(file)
        Archive.new(file).bundle_info
      else
        Bundle.new(file).info
      end

      include_keys = []
      exclude_keys = []
      Bundle::INFO_KEYS.each do |key|
        case options[key]
        when true
          include_keys << key
        when false
          exclude_keys << key
        end
      end

      keys = if include_keys.empty?
        Bundle::INFO_KEYS
      else
        include_keys
      end
      keys = keys - exclude_keys

      if keys.count > 1
        info = {}
        keys.each do |key|
          info[key] = bundle_info[key]
        end
        puts info.map{|key, value| "#{key} #{value}"}.join("\n")
      else
        keys.each do |key|
          puts bundle_info[key]
        end
      end
    end

    desc "sign [FILE]", "Sign a file with a DSA private key."
    option :key, type: :string, required: true, desc: "Path to a DSA private key."
    def sign(file = nil)
      source = if file
        File.binread(file)
      else
        STDIN.read
      end
      puts Signer.new(options[:key]).sign(source)
    end

    desc "markdown [FILE]", "Format Markdown text file in HTML."
    def markdown(file = nil)
      text = if file
        File.read(file)
      else
        STDIN.read
      end
      puts ReleaseNote.markdown(text)
    end
  end
end
