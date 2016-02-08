# encoding: utf-8

module PagesCore
  module HeadTagsHelper
    # Sets a document title.
    #
    #  document_title "Dashboard"
    #
    def document_title(*args)
      if args.any?
        @document_title = args.first
      else
        safe_join(
          [@document_title, PagesCore.config(:site_name)].compact.uniq,
          " - "
        )
      end
    end
    alias_method :page_title, :document_title

    # Returns true if document title has been set.
    def document_title?
      @document_title ? true : false
    end

    # Generates links for all RSS feeds. Specify
    # :include_hidden to also include hidden pages.
    #
    #  feed_tags
    #  feed_tags include_hidden: true
    #
    def feed_tags(options = {})
      feeds = Page.enabled_feeds(@locale, options)
      return unless feeds.any?
      feed_tags = [
        rss_link_tag(
          PagesCore.config(:site_name),
          pages_url(@locale, format: :rss)
        )
      ]
      if feeds.count < 1
        feed_tags += feeds.map do |page|
          rss_link_tag(
            "#{PagesCore.config(:site_name)}: #{page.name}",
            page_url(@locale, page, format: :rss)
          )
        end
      end
      safe_join(feed_tags, "\n")
    end

    # Outputs Google Analytics tracking code.
    #
    #  google_analytics_tags "UA-12345678-1"
    #
    def google_analytics_tags(account_id)
      javascript_tag(
        "var _gaq = _gaq || [];\n" \
          "_gaq.push(['_setAccount', '#{account_id}']);\n" \
          "_gaq.push(['_trackPageview']);\n" \
          "(function() {\n" \
          "var ga = document.createElement('script'); " \
          "ga.type = 'text/javascript'; ga.async = true;\n" \
          "ga.src = ('https:' == document.location.protocol ? 'https://ssl' " \
          ": 'http://www') + '.google-analytics.com/ga.js';\n" \
          "var s = document.getElementsByTagName('script')[0]; " \
          "s.parentNode.insertBefore(ga, s);\n" \
          "})();"
      )
    end

    # Outputs a HTML5 doctype and head tags, with document title
    # and relevant meta tags. Takes a block which will be placed
    # inside <head>.
    #
    #  <%= head_tag do %>
    #    <%= stylesheet_link_tag "application" %>
    #    <%= javascript_include_tag "application" %>
    #    <%= feed_tags %>
    #  <% end %>
    #
    def head_tag(&block)
      # The block output must be captured first
      block_output = block_given? ? capture(&block) : nil

      "<!doctype html>\n<html lang=\"#{I18n.locale}\">".html_safe +
        content_tag(:head) { safe_join(head_tag_contents(block_output), "\n") }
    end

    # Generates a link to an RSS feed.
    #
    #  rss_link_tag "My feed", "feed.rss"
    #
    def rss_link_tag(title, href)
      tag(
        :link,
        rel: "alternate",
        type: "application/rss+xml",
        title: title,
        href: href
      )
    end

    # Outputs Typekit tags.
    #
    #  typekit_tags "aadgrag"
    #
    def typekit_tags(kit_id)
      safe_join([
        javascript_include_tag("http://use.typekit.com/#{kit_id}.js"),
        javascript_tag("try{Typekit.load();}catch(e){}")
      ], "\n")
    end

    private

    def head_tag_contents(block_output)
      [
        tag(:meta, charset: "utf-8"),
        tag(:meta, "http-equiv" => "X-UA-Compatible", "content" => "IE=edge"),
        content_tag(:title, document_title),
        meta_description_tag,
        meta_keywords_tag,
        (tag(:link, rel: "image_src", href: meta_image) if meta_image?),
        open_graph_tags,
        csrf_meta_tags,
        block_output
      ]
    end
  end
end
