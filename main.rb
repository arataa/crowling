# -- coding: utf-8
require 'anemone'
require "kconv"
require 'rubygems'
require 'mongoid'
Mongoid.load!("./mongoid.yml", :development)

require './movie.rb'
require './yahoo.rb'
require './pia.rb'
require './imdb.rb'
require './review.rb'
require './actor.rb'
require './html.rb'
I18n.enforce_available_locales = false

yahoo = "http://movies.yahoo.co.jp/roadshow"
pia = "http://cinema.pia.co.jp/roadshow/"
imdb = "http://www.imdb.com/movies-in-theaters/?ref_=nv_mv_inth_1"
#Anemone.crawl("http://info.movies.yahoo.co.jp/detail/tymv/id346630/") do |anemone| 
#Anemone.crawl(yahoo) do |anemone| 
#Anemone.crawl(pia, depth_limit: 1) do |anemone| 
Anemone.crawl(imdb, depth_limit: 1) do |anemone| 
  anemone.on_every_page do |page| 
    if /yahoo.co.jp/ =~ page.url.to_s
      obj = Yahoo.new
      obj.read(page)
      if Yahoo.where(mid: obj.mid).size == 0
        obj.save! 
      else
        obj = Yahoo.where(mid: obj.mid).first
      end
      obj.set_reviews
    elsif /roadshow/ =~ page.url.to_s
      Pia.read(page)
    elsif /imdb/ =~ page.url.to_s
      Imdb.read(page)
    end
    exit
  end
end
