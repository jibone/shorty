# Links controller.
class LinksController < ApplicationController
  MAX_ATTEMPTS = 5 # retry 5 time when there is a collision when generating short code.

  def show
    @link = Link.find_by(short_code: params[:short_code])

    if @link.nil?
      render :not_found
      return
    end

    @clicks = @link.link_clicks
    @total_clicks = @clicks.count

    @analytics = grouped_click_analytics(@clicks)
  end

  def new
    @link = Link.new(flash[:link_params])
  end

  def create
    @link = Link.new(link_params)

    # Use timestamp for seed, might want to revisit this later
    seed = Time.current.to_i

    attempts = 0
    begin
      attempts += 1
      updated_link = ShortLinkCreator.new(@link, seed + attempts).call

      save(updated_link)
    rescue ActiveRecord::RecordNotUnique
      # If we hit a collision, we keep trying until we reach MAX_ATTEMPTS
      retry if attempts < MAX_ATTEMPTS
      failure
    end
  end

  def redirect
    @link = Link.find_by(short_code: params[:short_code])

    if @link
      ClickEventWriter.new(@link, request).call
      redirect_to @link.target_url, allow_other_host: true
    else
      render :not_found
    end
  end

  private

  def link_params
    params.require(:link).permit(:title, :target_url)
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

  def failure
    flash[:error] = t('link.create.flash.error')
    flash[:link_params] = link_params
    redirect_to new_links_path
  end

  def save(updated_link)
    if updated_link.valid?
      updated_link.save
      success(updated_link)
    else
      flash[:error] = updated_link.errors.full_messages.to_sentence
      flash[:link_params] = link_params
      redirect_to new_links_path
    end
  end
end
