# Links controller.
class LinksController < ApplicationController
  MAX_ATTEMPTS = 5 # retry 5 time when there is a collision when generating short code.

  def show
    @link = Link.find_by(short_code: params[:short_code])

    render :not_found if @link.nil?
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

    if @link.nil?
      render :not_found
    else
      redirect_to @link.target_url, allow_other_host: true
    end
  end

  private

  def link_params
    params.require(:link).permit(:title, :target_url)
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
