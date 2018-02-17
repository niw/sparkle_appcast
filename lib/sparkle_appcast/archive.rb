require "tmpdir"

module SparkleAppcast
  class Archive
    attr_reader :path

    def initialize(path)
      @path = File.expand_path(path)
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

    def bundle_info
      @bundle_info ||= Dir.mktmpdir do |tmpdir_path|
        unarchive!(tmpdir_path)

        app_paths = Dir.glob(File.join(tmpdir_path, "*.app"), File::FNM_CASEFOLD)
        if app_paths.size == 0
          raise RuntimeError.new("No application bundle found: #{path}")
        elsif app_paths.size > 1
          raise RuntimeError.new("Found multiple application bundles: #{app_paths.map{|path| File.basename(path)}}")
        else
          app_path = app_paths.first
          Bundle.new(app_path).info
        end
      end
    end

    private

    def unarchive!(destination_path)
      case File.basename(path)
      when /\.zip\z/i
        Kernel.system("/usr/bin/ditto", "-x", "-k", path, destination_path)
      when /\.tar\z/i
        Kernel.system("/usr/bin/tar", "-x", "-f", path, "-C", destination_path)
      when /\.tar\.gz\z/i, /\.tgz\z/i, /\.tar\.xz\z/i, /\.txz\z/i, /\.tar\.lzma\z/i
        Kernel.system("/usr/bin/tar", "-x", "-z", "-f", path, "-C", destination_path)
      when /\.tar\.bz2\z/i, /\.tbz\z/i
        Kernel.system("/usr/bin/tar", "-x", "-j", "-f", path, "-C", destination_path)
      else
        raise NotImplementedError.new("Disk image support is not implemented yet.")
      end

      unless $?.success?
        raise RuntimeError.new("Failed to expand archive: #{path}")
      end
    end
  end
end
