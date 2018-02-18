require "mustache"

module SparkleAppcast
  class ReleaseNote
    def self.markdown(text)
      Kramdown::Document.new(text, auto_ids: false).to_html
    end

    attr_reader :path

    def initialize(path)
      @path = path
    end

    def html(context = {})
      self.class.markdown(Mustache.render(text, context))
    end

    def text
      @text ||= File.read(path)
    end
  end
end
