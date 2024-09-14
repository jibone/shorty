require 'digest'

# TODO: add comment
class ShortLinkCreator
  MAX_ATTEMPTS = 5 # retry 5 time when there is a collision when generating short code.

  def initialize(link)
    @link = link
  end

  def call
    seed = Time.current.to_i
    attempts = 0
    begin
      attempts += 1
      # ShortCodeGenerator.new(@link, seed + attempts).call
      @link.short_code = generate_short_code(@link.target_url, seed + attempts)
      @link
    rescue ActiveRecord::RecordNotUnique
      # If we hit a collision, we keep trying until we reach MAX_ATTEMPTS
      retry if attempts < MAX_ATTEMPTS
      throw ActiveRecord::RecordNotUnique
    end
  end

  private

  def generate_short_code(target_url, seed)
    Digest::SHA256.hexdigest("#{target_url}#{seed}")[0..5] # TODO: make this configurable maybe?
  end
end
