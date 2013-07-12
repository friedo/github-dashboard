require 'instagram'

# Instagram Client ID from http://instagram.com/developer
Instagram.configure do |config|
  config.client_id = '730e9ddf10924b168102cc02a19a91f7'
end

SCHEDULER.every '10m', :first_in => 0 do |job|
  photos = Instagram.tag_recent_media("mongodb")
  if photos
    photos.map! do |photo|
      { photo: "#{photo.images.low_resolution.url}" }
    end
  end
  send_event('instamongo', photos: photos)
end
