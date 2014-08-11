# -- coding: utf-8
require 'anemone'
require "kconv"
require 'rubygems'
require 'mongoid'
require 'carrierwave/mongoid'

Mongoid.load!("./mongoid.yml", :development)

Dir[File.expand_path('../model', __FILE__) << '/*.rb'].each do |file|
  require file
end
I18n.enforce_available_locales = false

yahoo = "http://movies.yahoo.co.jp/roadshow"
pia = "http://cinema.pia.co.jp/roadshow/"
imdb = "http://www.imdb.com/movies-in-theaters/?ref_=nv_mv_inth_1"
tomato = "http://www.rottentomatoes.com/movie/in-theaters/"
#Anemone.crawl("http://info.movies.yahoo.co.jp/detail/tymv/id346630/") do |anemone| 
#Anemone.crawl(yahoo) do |anemone| 
#Anemone.crawl(pia, depth_limit: 1) do |anemone| 
#[pia, imdb].each do |u|
[pia, tomato].each do |u|
  Anemone.crawl(u, depth_limit: 1) do |anemone| 
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
        #ぴあ
        Pia.read(page)
      elsif /imdb/ =~ page.url.to_s
        Imdb.read(page)
      elsif /tomato/ =~ page.url.to_s
        RottenTomato.read(page)
      end
      next
    end
  end
end
