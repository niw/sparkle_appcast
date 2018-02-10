require "tmpdir"
require "plist"

module SparkleAppcast
  class Archive
    attr_reader :path

    def initialize(path)
      @path = File.expand_path(path)
    end

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

    def created_at
      File.birthtime(path)
    end

    def size
      File.size(path)
    end

    def data
      File.binread(path)
    end

    private

    # TODO: Support localizable string.

    def info_plist
      @info_plist ||= Dir.mktmpdir do |tmpdir_path|
        case File.basename(path)
        when /\.zip\z/i
          Kernel.system("/usr/bin/ditto", "-x", "-k", path, tmpdir_path)
        when /\.tar\z/i
          Kernel.system("/usr/bin/tar", "-x", "-f", path, "-C", tmpdir_path)
        when /\.tar\.gz\z/i, /\.tgz\z/i, /\.tar\.xz\z/i, /\.txz\z/i, /\.tar\.lzma\z/i
          Kernel.system("/usr/bin/tar", "-x", "-z", "-f", path, "-C", tmpdir_path)
        when /\.tar\.bz2\z/i, /\.tbz\z/i
          Kernel.system("/usr/bin/tar", "-x", "-j", "-f", path, "-C", tmpdir_path)
        else
          raise NotImplementedError.new("Disk image support is not implemented yet.")
        end

        unless $?.success?
          raise RuntimeError.new("Failed to expand archive: #{path}")
        end

        app_paths = Dir.glob(File.join(tmpdir_path, "*.app"), File::FNM_CASEFOLD)
        if app_paths.size == 0
          raise RuntimeError.new("No application bundle found: #{path}")
        elsif app_paths.size > 1
          raise RuntimeError.new("Found multiple application bundles: #{app_paths.map{|path| File.basename(path)}}")
        else
          app_path = app_paths.first
          info_plist_path = File.join(app_path, "Contents", "Info.plist")
          Plist.parse_xml(info_plist_path)
        end
      end
    end
  end
end
