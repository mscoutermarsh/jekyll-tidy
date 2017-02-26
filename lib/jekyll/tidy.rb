require "jekyll/tidy/version"

require "jekyll"
require "htmlbeautifier"
require "htmlcompressor"

JEKYLL_CONFIG = Jekyll.configuration({})

module Jekyll
  module Tidy
    class << self
      def exclude?(path)
        exclude_paths = JEKYLL_CONFIG.dig(:jekyll_tidy, :exclude)
        return exclude_paths.to_a.include?(path) unless exclude_paths.nil?
      end

      def compress_output?
        JEKYLL_CONFIG.dig(:jekyll_tidy, :compress_html)
      end

      def output_clean(output, compress = false)
        if compress
          return HtmlCompressor::Compressor.new.compress output
        else
          return HtmlBeautifier.beautify output
        end
      end
    end
  end
end

# Jekyll Hooks
# -------------------------------------

Jekyll::Hooks.register :documents, :post_render do |doc|
  unless Jekyll::Tidy::exclude?(doc.path, Jekyll::Tidy.compress_output?)
    doc.output = Jekyll::Tidy::output_clean(doc.output)
  end
end

Jekyll::Hooks.register :pages, :post_render do |page|
  unless Jekyll::Tidy::exclude?(page.path, Jekyll::Tidy.compress_output?)
    page.output = Jekyll::Tidy::output_clean(page.output)
  end
end
