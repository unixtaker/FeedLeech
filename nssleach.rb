$: << File.expand_path("../", __FILE__)
require 'webleech'

BASE_URL = 'http://nsscreencast.com'
page = load_uri (BASE_URL)

@casts = Array.new

page.css('div.episode').each do |ep|
 @casts << BASE_URL + ep.css('h3').first.children.css('a').first['href'] + '/play'
end

@casts.reverse!
@casts.each do |c|
 puts c
 detail_page = load_uri c
 needleech = detail_page.css('video').first.child['src']
 cmd = "wget -nc %s " % needleech
 puts cmd
 %x[#{cmd}]
end


