require "rexml/document"
require "time"

module SparkleAppcast
  class Rss
    REQUIRED_FILEDS = [
      :url,
      :length,
      :version,
      :dsa_signature
    ]

    attr_reader :params

    def initialize(params)
      REQUIRED_FILEDS.each do |field|
        unless params[field]
          raise ArgumentError.new("Missing #{field} param")
        end
      end
      @params = params
    end

    def to_s
      StringIO.new.tap do |output|
        output << %(<?xml version="1.0" encoding="UTF-8"?>\n)
        formatter = REXML::Formatters::Pretty.new(2)
        formatter.compact = true
        formatter.write(document, output)
      end.string
    end

    private

    def document
      @document ||= REXML::Document.new.tap do |document|
        document.context = {
          # Use double quote for attributes escape.
          attribute_quote: :quote
        }

        # <rss ... > ... </rss>
        document.add_element("rss").tap do |rss|
          rss.add_namespace("xmlns:sparkle", "http://www.andymatuschak.org/xml-namespaces/sparkle")
          rss.add_namespace("xmlns:dc", "http://purl.org/dc/elements/1.1/")
          rss.add_attribute("version", "2.0")

          # <channel> ... </channel>
          rss.add_element("channel").tap do |channel|
            channel.add_element("title").add_text(params[:channel_title]) if params[:channel_title]
            channel.add_element("description").add_text(params[:channel_description]) if params[:channel_description]
            channel.add_element("link").add_text(params[:channel_link]) if params[:channel_link]
            channel.add_element("language").add_text(params[:language]) if params[:language]

            # <item> ... </item>
            channel.add_element("item").tap do |item|
              item.add_element("title").add_text(params[:title]) if params[:title]
              item.add_element("description").add(REXML::CData.new(params[:description])) if params[:description]
              item.add_element("pubDate").add_text(publish_date) if publish_date

              # <enclosure ... />
              item.add_element("enclosure").tap do |enclosure|
                enclosure.add_attribute("url", params[:url])
                enclosure.add_attribute("type", "application/octet-stream")
                enclosure.add_attribute("length", params[:length])
                enclosure.add_attribute("sparkle:version", params[:version])
                enclosure.add_attribute("sparkle:shortVersionString", params[:short_version_string]) if params[:short_version_string]
                enclosure.add_attribute("sparkle:dsaSignature", params[:dsa_signature])
                enclosure.add_attribute("sparkle:minimumSystemVersion", params[:minimum_system_version]) if params[:minimum_system_version]
              end
            end
          end
        end
      end
    end

    def publish_date
      case params[:publish_date]
      when nil
        nil
      when Time
        params[:publish_date].utc.rfc2822
      else
        params[:publish_date]
      end
    end
  end
end
