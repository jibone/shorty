require 'uri'

# LinksController
#
# Handles link creations, deletions, and details.
# The 'redirect' method will redirects to link's target_url.
class LinksController < ApplicationController
  def show
    link = ShortCodeCacheReader.new(params[:short_code]).call

    render :not_found and return if link.nil?

    @link = backfill_title(link)

    @current_user = current_user
    @qr_code = QrcodeGenerator.new(@link.full_short_url(request)).call

    @clicks = @link.link_clicks
    @analytics = LinkAnalyticCalculator.new(@clicks).call
  end

  def new
    @current_user = current_user
    @link = Link.new(flash[:link_params])
  end

  def create
    p = link_params
    failure(t('link.create.flash.invalid')) and return unless url_valid?(p[:target_url])

    title = LinkTitleFetcher.new(p[:target_url]).call
    @link = build_link({ label: p[:label], target_url: p[:target_url], title: })

    save_link(@link)
  end

  def destroy
    @link = Link.find_by(short_code: params[:short_code])

    render :not_found and return if @link.nil?

    @user = current_user
    delete_link(@link, @user)
  end

  def redirect
    @link = ShortCodeCacheReader.new(params[:short_code]).call

    if @link
      ClickEventWriter.new(@link, request).call
      redirect_to @link.target_url, allow_other_host: true
    else
      render :not_found
    end
  end

  private

  def link_params
    params.require(:link).permit(:label, :target_url)
  end

  def url_valid?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue StandardError
    false
  end

  def build_link(link_params)
    if logged_in?
      current_user.links.build(link_params)
    else
      Link.new(link_params)
    end
  end

  def save_link(link)
    if ShortLinkCreator.new(link).call
      ShortCodeCacheWriter.new(link.short_code, link).call
      success(link)
    else
      failure(link.errors.full_messages.to_sentence)
    end
  rescue ActiveRecord::RecordNotUnique
    failure
  end

  def delete_link(link, user)
    if link.user == user
      ShortCodeCacheRemover.new(link.short_code).call
      link.destroy
      flash[:notice] = t('link.delete.success')
    else
      flash[:alert] = t('link.delete.not_authorized')
    end
    redirect_to users_dashboard_path
  end

  def backfill_title(link)
    return link if link.respond_to?(:title) && link.title.present?

    updated_link = Link.find(link.id)
    updated_link.title = LinkTitleFetcher.new(updated_link.target_url).call
    updated_link.save
    updated_link
  end

  def success(updated_link)
    flash[:success] = t('link.create.flash.success')
    redirect_to short_code_links_path(updated_link.short_code)
  end

  def failure(error_msg = t('link.create.flash.error'))
    flash[:error] = error_msg
    flash[:link_params] = link_params
    redirect_to new_links_path
  end
end
