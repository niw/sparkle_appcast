require "mustache"

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

    PARAMS_EXCLUDED_FROM_TEMPLATE = [
      # The template is applied already to `description` value. See `base_params`.
      :description,
      :dsa_signature
    ]

    def rss_params
      @rss_params ||= base_params.inject({}) do |params, (key, value)|
        unless PARAMS_EXCLUDED_FROM_TEMPLATE.include?(key)
          case value
          when String
            value = Mustache.render(value, context)
          end
        end
        params[key] = value
        params
      end
    end

    def base_params
      {
        # channel
        channel_link: "{{feed_url}}",

        # item
        description: release_note.html(context),
        publish_date: archive.created_at,

        # enclosure
        url: url,
        length: archive.size,
        version: "{{bundle_version}}",
        short_version_string: "{{bundle_short_version_string}}",
        minimum_system_version: "{{minimum_system_version}}",
        dsa_signature: dsa_signature
      }.merge(params)
    end

    def dsa_signature
      @dsa_signature ||= signer.sign(archive.data)
    end

    def context
      @context ||= archive.bundle_info
    end
  end
end
