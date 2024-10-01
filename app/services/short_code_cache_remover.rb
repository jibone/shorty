# ShortCodeCacheRemover
#
# Delete the cache.
class ShortCodeCacheRemover
  def initialize(short_code)
    @short_code = short_code
    @namespace = 'shorty'
  end

  def call
    Rails.logger.info "Cache delete: #{@namespace}:#{@short_code}"
    Rails.cache.delete("#{@namespace}:#{@short_code}")
  end
end
