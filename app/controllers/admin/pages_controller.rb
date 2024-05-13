# frozen_string_literal: true

module Admin
  class PagesController < Admin::AdminController
    include PagesCore::Admin::PageJsonHelper

    before_action :find_page, only: %i[show edit update destroy move]

    require_authorization

    def index
      @pages = Page.admin_list(content_locale)
    end

    def deleted
      @pages = Page.deleted.by_updated_at.in_locale(content_locale)
    end

    def search
      return if search_query.blank?

      @search_documents =
        SearchDocument.where(searchable_type: "Page")
                      .search(search_query, locale: content_locale)
                      .paginate(per_page: 50, page: params[:page])
    end

    def show
      redirect_to edit_admin_page_url(content_locale, @page)
    end

    def new
      build_params = params[:page] ? page_params : nil
      @page = build_page(content_locale, build_params)
      @page.parent = Page.find_by(id: params[:parent])
    end

    def edit; end

    def create
      @page = build_page(content_locale, page_params).tap(&:save)
      if @page.valid?
        respond_with_page(@page) do
          redirect_to(edit_admin_page_url(content_locale, @page))
        end
      else
        render action: :new
      end
    end

    def update
      if @page.update(page_params)
        respond_with_page(@page) do
          flash[:notice] = t("pages_core.changes_saved")
          redirect_to edit_admin_page_url(content_locale, @page)
        end
      else
        render action: :edit
      end
    end

    def move
      parent = params[:parent_id] ? Page.find(params[:parent_id]) : nil
      @page.update(parent:, position: params[:position])
      respond_with_page(@page) { redirect_to admin_pages_url(content_locale) }
    end

    def destroy
      Page.find(params[:id]).flag_as_deleted!
      redirect_to admin_pages_url(content_locale)
    end

    private

    def build_page(locale, attributes = nil)
      Page.new.localize(locale).tap do |page|
        page.author = default_author || current_user
        page.attributes = attributes if attributes
      end
    end

    def default_author
      User.find_by(email: PagesCore.config.default_author)
    end

    def page_attributes
      %i[template user_id status feed_enabled published_at redirect_to
         image_link news_page unique_name pinned parent_page_id serialized_tags
         meta_image_id starts_at ends_at all_day image_id path_segment
         meta_title meta_description open_graph_title open_graph_description]
    end

    def page_params
      params.require(:page).permit(
        PagesCore::Templates::TemplateConfiguration.all_blocks +
        page_attributes,
        page_images_attributes: %i[id position image_id primary _destroy],
        page_files_attributes: %i[id position attachment_id _destroy]
      )
    end

    def find_page
      @page = Page.find(params[:id]).localize(content_locale)
    end

    def respond_with_page(page, &block)
      respond_to do |format|
        format.html(&block)
        format.json { render json: page_json(page) }
      end
    end
  end
end
