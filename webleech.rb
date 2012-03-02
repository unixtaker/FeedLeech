require 'nokogiri'
require 'open-uri'
require 'Base64'


def load_uri(url)
  puts "loading" + url
  hashtag = Base64.urlsafe_encode64 url
  if ( not File.exists? hashtag )
    puts "Caching " + url + " to file " + hashtag
    f= File.new(hashtag,"w")
    webp = open(url)
    webp.each_line { |line| f.write line }
    webp.close
    f.close 
  end    
  puts "opening " + hashtag
  Nokogiri::HTML open hashtag 
end

