# encoding: utf-8

class PagesCore::ApplicationController < ActionController::Base
  include PagesCore::Authentication
  include PagesCore::ExceptionHandler
  include PagesCore::ProcessTitler
  include PagesCore::OpenidHelper

  before_action :domain_cache
  before_action :set_locale
  after_action  :set_content_language_header

  protected

  def domain_cache
    if PagesCore.config(:domain_based_cache)
      @@default_page_cache_directory ||= @@page_cache_directory
      @@page_cache_directory = File.join(@@default_page_cache_directory, request.domain)
    end
  end

  # Sets @locale from params[:locale], with Language.default as fallback
  def set_locale
    if params[:language]
      ActiveSupport::Deprecation.warn "params[:language] is deprecated, use params[:locale]"
    end
    @language = @locale = params[:locale] || params[:language] || Language.default
  end

  def set_content_language_header
    if @locale && definition = Language.definition(@locale.to_s)
      headers['Content-Language'] = definition.iso639_1
    end
  end
end
