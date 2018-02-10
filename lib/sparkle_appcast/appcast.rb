module SparkleAppcast
  class Appcast
    attr_reader :signer, :archive, :release_note, :url, :params

    def initialize(archive, signer, url, release_note, params = {})
      @archive = archive
      @signer = signer
      @url = url
      @release_note = release_note
      @params = params
    end

    def rss
      Rss.new(rss_params)
    end

    private

    def rss_params
      {
        channel_link: archive.feed_url,
        title: title,
        description: release_note.html,
        publish_date: archive.created_at,
        url: url,
        length: archive.size,
        version: archive.bundle_version,
        short_version_string: archive.bundle_short_version_string,
        minimum_system_version: archive.minimum_system_version,
        dsa_signature: dsa_signature
      }.merge(params)
    end

    def title
      "#{archive.bundle_name} #{archive.bundle_short_version_string} (#{archive.bundle_version})"
    end

    def dsa_signature
      @dsa_signature ||= signer.sign(archive.data)
    end
  end
end
