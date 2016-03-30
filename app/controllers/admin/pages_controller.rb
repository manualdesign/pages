# encoding: utf-8

module Admin
  class PagesController < Admin::AdminController
    include PagesCore::Admin::NewsPageController

    before_action :find_page, only: [:show, :edit, :preview, :update, :destroy,
                                     :delete_meta_image, :move]
    before_action :find_categories

    require_authorization(Page, proc { @page },
                          collection: [:index, :news, :new, :new_news, :create],
                          member: [:show, :edit, :preview, :update, :destroy,
                                   :delete_meta_image, :move])

    def index
      @root_pages = Page.roots.in_locale(@locale).visible
    end

    def show
      redirect_to edit_admin_page_url(@locale, @page)
    end

    def new
      @page = build_page(@locale)
      if params[:parent]
        @page.parent = Page.find(params[:parent])
      elsif @news_pages
        @page.parent = @news_pages.first
      end
    end

    def create
      @page = build_page(@locale, page_params, param_categories)
      if @page.valid?
        @page.save
        respond_with_page(@page) do
          redirect_to(edit_admin_page_url(@locale, @page))
        end
      else
        render action: :new
      end
    end

    def edit
      render action: :edit
    end

    def update
      if @page.update(page_params)
        @page.categories = param_categories
        respond_with_page(@page) do
          flash[:notice] = "Your changes were saved"
          redirect_to edit_admin_page_url(@locale, @page)
        end
      else
        edit
      end
    end

    def move
      parent = params[:parent_id] ? Page.find(params[:parent_id]) : nil
      @page.update(parent: parent, position: params[:position])
      respond_with_page(@page) { redirect_to admin_pages_url(@locale) }
    end

    def destroy
      Page.find(params[:id]).flag_as_deleted!
      redirect_to admin_pages_url(@locale)
    end

    def delete_meta_image
      @page.meta_image.destroy
      flash[:notice] = "The image was deleted"
      redirect_to edit_admin_page_url(@locale, @page, anchor: "metadata")
    end

    private

    def build_page(locale, attributes = nil, categories = nil)
      Page.new.localize(locale).tap do |page|
        page.author = default_author || current_user
        if attributes
          page.attributes = attributes
          page.comments_allowed = page.template_config.value(:comments_allowed)
        end
        page.categories = categories if categories
      end
    end

    def default_author
      return unless PagesCore.config.default_author
      User.where(email: PagesCore.config.default_author).first
    end

    def page_attributes
      [:template, :user_id, :status, :feed_enabled, :published_at,
       :redirect_to, :comments_allowed, :image_link, :news_page,
       :unique_name, :pinned, :parent_page_id, :serialized_tags, :meta_image]
    end

    def page_params
      params.require(:page).permit(Page.localized_attributes + page_attributes)
    end

    def param_categories
      return [] unless params[:category] && params[:category].any?
      params[:category].map { |k, _| Category.find(k.to_i) }
    end

    def find_page
      @page = Page.find(params[:id]).localize(@locale)
    end

    def find_categories
      @categories = Category.order("name")
    end

    def respond_with_page(page)
      respond_to do |format|
        format.html { yield }
        format.json { render json: page, serializer: PageTreeSerializer }
      end
    end
  end
end
