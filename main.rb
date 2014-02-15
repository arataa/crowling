# -- coding: utf-8
require 'anemone'
require "kconv"
require './yahoo.rb'
require './pia.rb'
require './html.rb'

#yahoo = "http://movies.yahoo.co.jp/roadshow/calendar/tw2.php"
yahoo = "http://movies.yahoo.co.jp/roadshow"
pia = "http://cinema.pia.co.jp/roadshow/"
#Anemone.crawl("http://info.movies.yahoo.co.jp/detail/tymv/id346630/") do |anemone| 
Anemone.crawl(yahoo, depth_limit: 1) do |anemone| 
#Anemone.crawl(pia, depth_limit: 1) do |anemone| 
#Anemone.crawl("http://www.imdb.com/movies-in-theaters/?ref_=nv_mv_inth_1") do |anemone| 
#Anemone.crawl("http://www.imdb.com/title/tt1800246/") do |anemone| 
  anemone.on_every_page do |page| 
    if /yahoo.co.jp/ =~ page.url.to_s
      obj = Yahoo.new(page)
    else
      Pia.new(page)
    end
    obj.reviews
    exit

    #IMDb
    #doc.css('h1.header span').each do |title|
    #  p title.inner_text()
    #end
    
    #doc.css('h1 strong').each do |title|
    #  p title.inner_text().encoding
    #end
    #p page.url
    #p page.doc.xpath("//head/title/text()").first.to_s if page.doc
    #p page.body[0..200]
  end
end
