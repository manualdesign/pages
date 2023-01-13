# frozen_string_literal: true

module PagesCore
  module Admin
    module AdminHelper
      include PagesCore::Admin::ContentTabsHelper
      include PagesCore::Admin::DeprecatedAdminHelper
      include PagesCore::Admin::DateRangeHelper
      include PagesCore::Admin::ImageUploadsHelper
      include PagesCore::Admin::LocalesHelper
      include PagesCore::Admin::PageJsonHelper
      include PagesCore::Admin::LabelledFieldHelper
      include PagesCore::Admin::TagEditorHelper

      def rich_text_area_tag(name, content = nil, options = {})
        react_component("RichTextArea",
                        options.merge(id: sanitize_to_id(name),
                                      name: name,
                                      value: content))
      end

      def link_separator
        safe_join [" ", tag.span("|", class: "separator"), " "]
      end

      def locale_links(&block)
        return unless PagesCore.config.localizations?

        safe_join(
          PagesCore.config.locales.map do |locale, name|
            link_to_unless_current(name, block.call(locale))
          end, link_separator
        )
      end

      def month_name(month)
        %w[January February March April May June July August September October
           November December][month - 1]
      end
    end
  end
end
