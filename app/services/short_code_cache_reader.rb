# ShortCodeCacheRead
#
# Read from cahce or database
class ShortCodeCacheReader
  def initialize(short_code)
    @short_code = short_code
    @namespace = 'shorty'
  end

  def call
    Rails.logger.info "Read cache: #{@namespace}:#{@short_code}"
    cached_link = Rails.cache.read("#{@namespace}:#{@short_code}")
    return cached_link if cached_link.present?

    Rails.logger.info "Cache missed: #{@namespace}:#{@short_code}"
    link = Link.find_by(short_code: @short_code)
    ShortCodeCacheWriter.new(link.short_code, link).call if link.present?
    link
  end
end
