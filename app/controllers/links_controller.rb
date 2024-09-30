require 'uri'

# LinksController
#
# Handles link creations, deletions, and details.
# The 'redirect' method will redirects to link's target_url.
class LinksController < ApplicationController
  def show
    @link = ShortCodeCacheRead.new(params[:short_code]).call

    render :not_found and return if @link.nil?

    @current_user = current_user
    @short_url_full = @link.full_short_url(request)
    @qr_code = QrcodeGenerator.new(@short_url_full).call

    @clicks = @link.link_clicks
    @total_clicks = @clicks.count

    @analytics = grouped_click_analytics(@clicks)
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

    if @link.nil?
      render :not_found
      return
    end

    @user = current_user
    delete_link(@link, @user)
  end

  def redirect
    @link = ShortCodeCacheRead.new(params[:short_code]).call

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
      ShortCodeCacheDelete.new(link.short_code).call
      link.destroy
      flash[:notice] = t('link.delete.success')
    else
      flash[:alert] = t('link.delete.not_authorized')
    end
    redirect_to users_dashboard_path
  end

  # TODO: move this to new analytics service object.
  # Logic should not be in controller or model
  def grouped_click_analytics(clicks)
    {
      clicks_by_country: clicks.group(:country).count,
      clicks_by_device: clicks.group(:device_type).count,
      clicks_by_browser: clicks.group(:browser_name).count,
      clicks_by_os: clicks.group(:os_name).count,
      clicks_by_referer: clicks.group(:referer).count,
    }
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
