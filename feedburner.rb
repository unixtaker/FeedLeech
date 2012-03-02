$: << File.expand_path("../", __FILE__)
require 'webleech'
require 'optparse'

options = {}

optparse = OptionParser.new do |opts|
    opts.banner = "Usage: tww.rb [options]"
    options[:OUTPUT_FOLDER] = "./"
    opts.on('-o','--outdir=[DIR]', 'Set the download location') do |outdir|
        options[:OUTPUT_FOLDER] = outdir
        puts "Output folder set to: %s" % outdir
    end
        # dummy run will not execute any changes    
    
    options[:dummy_run] = false
    opts.on('-d','--dummy','Do not download files') do 
        options[:dummy_run] = true
    end
   
    options[:seriesname] = "TheWoodWhisperer"
    opts.on('-s','--series','The Feedburner username/url to use.') do |series|
	    options[:seriesname] = series
    end

    options[:quiet] = false
    opts.on('-q','--quiet','Turn off all debug output') do 
        options[:quiet] = true
    end
    
    opts.on('-h','--help','Display this screen' ) do
        puts opts
        exit
    end
        
end

def download_episode (title,weblink,description, options)
    if not options[:quiet]
      puts title
      puts weblink
      puts description
    end
    tinfo = title.sub("\u2013","-").split('-')
    if ( tinfo.length > 1 )
        episode = tinfo[0].strip
        title = tinfo[1].strip.gsub(" ",".")
        localname = weblink.split('/').last
        finalname = "%s%s.E%03d.%s.mp4" % [ options[:OUTPUT_FOLDER], options[:seriesname], episode.to_i, title ]
        
        if not options[:quiet]
          puts  "Ep: %03d Title: %s" % [ episode.to_i, title ] 
          puts '     ' + weblink
          puts '     ' + description
        end 
        
        if ( File.exists?  finalname )
            puts "Nothing to do, file already downloaded"
            exit
        end
        
        puts "Download file from: %s to %s" % [weblink, finalname ] if not options[:quiet]
        cmd = "curl -L %s -o \"%s\"" % [weblink, finalname ] 
        if options[:dummy_run]
            puts cmd
        else
            %x[#{cmd}]
        end 
    else
        puts "Couldn't identify the episode number for: %s" % title
    end
end

# this works when you save the html from chrome
def extract_video_page_urls(webpage,options)
    puts "Extracting data from html5 data"
    webpage.css('li.regularitem').each do |post|
      link = post.css('h4.itemtitle').css('a').first
      description = post.css('div.itemcontent').first.text
      download_episode(link.child.text,link['href'],description, options)
    end
end

# podcast/itunes 1.0 dtd
def extract_videos_from_itunes(webpage,options)
    puts "Extracting information from iTunes podcast"
    webpage.xpath('//item').each do |item|
       title = item.xpath('title').text if item.xpath('title')
       link = item.xpath('guid').text if item.xpath('guid')
       desc = item.xpath('description').text if item.xpath('description')
       download_episode(title,link,desc,options)
    end
end


optparse.parse!
        
page = load_uri 'http://feeds.feedburner.com/' + options[:seriesname]

extract_videos_from_itunes(page,options) if ( page.xpath("//namespace::itunes"))
extract_video_page_urls(page,options) if ( !page.xpath("//namespace::itunes"))
