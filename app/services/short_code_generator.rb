require 'digest'

# Short Link Creator service
class ShortCodeGenerator
  attr_reader :link, :seed

  def initialize(link, seed)
    @link = link
    @seed = seed
  end

  def call
    link.short_code = generate_short_code
    link
  end

  private

  def generate_short_code
    Digest::SHA256.hexdigest("#{link.target_url}#{seed}")[0..5] # TODO: make this configurable maybe?
  end
end
