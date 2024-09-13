# ShortCodeCacheWriter
#
# Write short code and target url pair to cache.
class ShortCodeCacheWriter
  def initialize(short_code, link)
    @short_code = short_code
    @link = link
    @namespace = 'shorty'
  end

  def call
    Rails.logger.info "Write cache: #{@namespace}:#{@short_code} with #{@link}"
    Rails.cache.write("#{@namespace}:#{@short_code}", @link, expires_in: 7.days)
  end
end
