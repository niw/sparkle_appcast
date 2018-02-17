require "plist"

module SparkleAppcast
  class Bundle
    INFO_KEYS = [
      :bundle_name,
      :bundle_version,
      :bundle_short_version_string,
      :minimum_system_version,
      :feed_url
    ]

    attr_reader :path

    def initialize(path)
      @path = File.expand_path(path)
    end

    def [](key)
      info[key]
    end

    def info
      @info ||= INFO_KEYS.inject({}) do |info, key|
        info[key] = self.send(key)
        info
      end
    end

    private

    # TODO: Support localizable string.

    def bundle_name
      info_plist["CFBundleDisplayName"] || info_plist["CFBundleName"]
    end

    def bundle_version
      info_plist["CFBundleVersion"]
    end

    def bundle_short_version_string
      info_plist["CFBundleShortVersionString"]
    end

    def minimum_system_version
      info_plist["LSMinimumSystemVersion"]
    end

    def feed_url
      info_plist["SUFeedURL"]
    end

    def info_plist
      @info_plist ||= Plist.parse_xml(File.join(path, "Contents", "Info.plist"))
    end
  end
end
