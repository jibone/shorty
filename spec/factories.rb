# the Link class
FactoryBot.define do
  factory :user do
    username { "Jibone" }
    password_digest { "password" }
  end

  factory :link_click do
    association :link
    ip_address { '127.0.0.1' }
    country { 'MY' }
    region { ' Asia' }
    city { 'Kuala Lumpur' }
    device_type { 'mobile' }
    browser_name { 'Chrome' }
    browser_version { 90.0 }
    os_name { 'iOS' }
    os_version { '14.4' }
    referer { 'http://jiboneus.com' }
  end

  factory :link do
    label { "Jibone's blog" }
    title { "jshamsul.com" }
    target_url { "https://jshamsul.com" }
    short_code { "qwerty" }
  end
end
