# encoding: utf-8

class Page < ActiveRecord::Base
  include PagesCore::HumanizableParam
  include PagesCore::PageTree
  include PagesCore::Sweepable
  include PagesCore::Taggable
  include PagesCore::Templateable

  belongs_to :author, class_name: "User", foreign_key: :user_id

  has_and_belongs_to_many :categories, join_table: 'pages_categories'

  belongs_to_image :image

  has_many :page_images, -> { order("position") }

  has_many :images,
           -> { where("`page_images`.`primary` = ?", false).order("position") },
           through:    :page_images

  has_many :comments,
           class_name: 'PageComment',
           dependent:  :destroy

  has_many :page_files,
           -> { order("position") },
           class_name: 'PageFile',
           dependent:  :destroy

  acts_as_list scope: :parent_page

  localizable do
    attribute :name
    attribute :body
    attribute :excerpt
    attribute :headline
    attribute :boxout

    # Get attributes from the template configuration
    PagesCore::Templates::TemplateConfiguration.all_blocks.each do |block|
      attribute block
    end
  end

  validates_format_of     :redirect_to, with: /\A(\/|https?:\/\/)/, allow_nil: true, allow_blank: true
  validates_format_of     :unique_name, with: /\A[\w\d_\-]+\z/, allow_nil: true, allow_blank: true
  validates_uniqueness_of :unique_name, allow_nil: true, allow_blank: true

  before_validation :published_at
  before_validation :set_autopublish
  before_save       :set_delta
  after_save        :ensure_page_images_contains_primary_image
  after_save        :queue_autopublisher

  scope :by_date,    -> { order('published_at DESC') }
  scope :published,  -> { where(status: 2, autopublish: false) }
  scope :visible,    -> { where('status < 4') }
  scope :news_pages, -> { visible.where(news_page: true) }

  class << self

    def archive_finder
      PagesCore::ArchiveFinder.new(all, timestamp: :published_at)
    end

    # Find all published and feed enabled pages
    def enabled_feeds(locale, options={})
      conditions = (options[:include_hidden]) ? 'status IN (2,3)' : 'status = 2'
      Page.where(feed_enabled: true).where(conditions).localized(locale)
    end

    def status_labels
      {
        0 => "Draft",
        1 => "Reviewed",
        2 => "Published",
        3 => "Hidden",
        4 => "Deleted"
      }
    end
  end

  def comments_closed_after_time?
    if PagesCore.config.close_comments_after.nil?
      false
    else
      (Time.now - self.published_at) > PagesCore.config.close_comments_after
    end
  end

  def comments_allowed?
    if self.comments_closed_after_time?
      false
    else
      self[:comments_allowed]
    end
  end

  def extended?
    excerpt? && body?
  end

  def empty?
    !body? && !excerpt?
  end
  alias :blank? :empty?

  def excerpt_or_body
    excerpt? ? excerpt : body
  end

  def files
    page_files.in_locale(self.locale)
  end

  def headline_or_name
    headline? ? headline : name
  end

  # Does this page have an image?
  def image?
    self.image_id?
  end

  # Get subpages
  def pages(options=nil)
    subpages = self.children.published.order(self.news_page? ? "pinned DESC, #{self.content_order}" : self.content_order)
    if self.locale?
      subpages = subpages.localized(self.locale)
    end
    subpages
  end

  # Return the status of the page as a string
  def status_label
    self.class.status_labels[self.status]
  end

  def flag_as_deleted!
    update(status: 4)
  end

  # Get publication date, which defaults to the creation date
  def published_at
    self[:published_at] ||= self.created_at
  end

  # Returns boolean true if page has a valid redirect
  def redirects?
    self.redirect_to?
  end

  def redirect_path(params={})
    path = self.redirect_to
    if path.start_with? "/"
      params.each do |key, value|
        raise "redirect_url param must be a string" unless value.kind_of?(String)
        path.gsub!("/:#{key.to_s}", "/#{value}")
      end
    end
    path
  end

  # Returns true if this page's children is reorderable
  def reorderable_children?
    !self.content_order? || self.content_order =~ /position/
  end

  # Returns true if this page is reorderable
  def reorderable?
    !self.parent || !self.parent.content_order? || self.parent.content_order =~ /position/
  end

  def draft?
    status == 0
  end

  def reviewed?
    status == 1
  end

  def published?
    status == 2 && !autopublish?
  end

  def hidden?
    status == 3
  end

  def deleted?
    status == 4
  end

  def to_param
    humanized_param(self.name)
  end

  def content_order
    self[:content_order] || 'position'
  end

  def to_xml(options = {})
    # Always skip these
    options[:except] = [:comments_count, :byline, :delta, :last_comment_at, :image_id] + Array(options[:except])

    super(options) do |xml|

      # Localizations
      self.template_config.enabled_blocks.each do |localizable_name, block_options|
        xml.tag!(localizable_name.to_sym) do |field|
          self.locales.each do |locale|
            field.tag!(locale.to_sym, self.localize(locale).send(localizable_name))
          end
        end
      end

      # Tags
      self.tags.to_xml(builder: xml, skip_instruct: true, only: [:name])

      # Images
      if options[:images]
        xml.images do |images_xml|
          self.page_images.each{ |page_image| page_image.to_xml(builder: images_xml, skip_instruct: true, only: [:image_id, :primary]) }
        end
      end

      # Comments
      if options[:comments]
        xml.comments do |comments_xml|
          self.comments.each{|comment| comment.to_xml(except: [:page_id], builder: comments_xml, skip_instruct: true)}
        end
      end

      # Subpages
      if options[:pages]
        subpages = (options[:pages] == :all) ? self.children : self.pages
        xml.pages do |pages_xml|
          self.pages.each{ |page| page.to_xml(options.merge({builder: pages_xml, skip_instruct: true})) }
        end
      end
    end
  end

  private

  def ensure_page_images_contains_primary_image
    if image_id? && image_id_changed?
      if page_image = page_images.where(image_id: image_id).first
        page_image.update(primary: true)
      else
        page_images.create(image_id: image_id, primary: true)
      end
    end
  end

  def set_autopublish
    self.autopublish = published_at? && published_at > Time.now
    true
  end

  def set_delta
    delta = true
  end

  def queue_autopublisher
    if self.autopublish?
      Autopublisher.queue!
    end
  end

end
