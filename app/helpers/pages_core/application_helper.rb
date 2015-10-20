# encoding: utf-8

# Methods added to this helper will be available to all templates
# in the application.
module PagesCore
  module ApplicationHelper
    include PagesCore::HeadTagsHelper
    include PagesCore::ImagesHelper
    include PagesCore::PagePathHelper

    def page_link(page, options = {})
      link_locale = options[:locale] || locale
      page.localize(link_locale) do |p|
        title = options[:title] || p.name.to_s
        return title unless conditional_options?(options)
        url = if p.redirects?
                p.redirect_path(locale: link_locale)
              else
                page_path(link_locale, p)
              end
        link_to(title, url, class: options[:class])
      end
    end

    def unique_page(page_name, &block)
      locale = @locale || I18n.default_locale.to_s
      page = Page.where(unique_name: page_name).first
      if page && block_given?
        output = capture(page.localize(locale), &block)
        concat(output)
      end
      (page) ? page.localize(locale) : nil
    end

    private

    def conditional_options?(options = {})
      if options.key?(:if)
        options[:if]
      elsif options.key?(:unless)
        !options[:unless]
      else
        true
      end
    end
  end
end
