# the Link class
FactoryBot.define do
  factory :link do
    title { "Jibone's blog" }
    target_url { "https://jshamsul.com" }
    short_code { "qwerty" }
  end
end
