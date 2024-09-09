# Links controller.
class LinksController < ApplicationController
  MAX_ATTEMPTS = 5 # retry 5 time when there is a collision when generating short code.

  def show
    @link = Link.find_by(short_code: params[:short_code])

    render :not_found if @link.nil?
  end

  def new
    @link = Link.new
  end

  def create
    @link = Link.new(link_params)

    # Use timestamp for seed, might want to revisit this later
    seed = Time.current.to_i

    attempts = 0
    begin
      attempts += 1
      updated_link = ShortLinkCreator.new(@link, seed + attempts).call

      success(updated_link) if updated_link.save
    rescue ActiveRecord::RecordNotUnique
      # If we hit a collision, we keep trying until we reach MAX_ATTEMPTS
      retry if attempts < MAX_ATTEMPTS
      failure
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
    flash.now[:error] = t('link.create.flash.error')
    render :new
  end
end
