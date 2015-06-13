# -- coding: utf-8
require 'anemone'
require "kconv"
require 'rubygems'
require 'mongoid'
require 'carrierwave/mongoid'
require 'capybara'
require 'capybara/poltergeist'

Mongoid.load!("./mongoid.yml", :development)

Dir[File.expand_path('../model', __FILE__) << '/*.rb'].each do |file|
  require file
end
I18n.enforce_available_locales = false

yahoo = "http://movies.yahoo.co.jp/roadshow"
pia = "http://cinema.pia.co.jp/roadshow/"
imdb = "http://www.imdb.com/movies-in-theaters/?ref_=nv_mv_inth_1"
tomato = 'http://www.rottentomatoes.com/browse/in-theaters/'
#Anemone.crawl("http://info.movies.yahoo.co.jp/detail/tymv/id346630/") do |anemone| 
#Anemone.crawl(yahoo) do |anemone| 
#Anemone.crawl(pia, depth_limit: 1) do |anemone| 
#[pia, imdb].each do |u|
[tomato].each do |u|
#[pia, tomato].each do |u|
  if /yahoo.co.jp/ =~ u
    obj = Yahoo.new
    obj.read(u)
    if Yahoo.where(mid: obj.mid).size == 0
      obj.save! 
    else
      obj = Yahoo.where(mid: obj.mid).first
    end
    obj.set_reviews
  elsif /roadshow/ =~ u
    #ぴあ
    Pia.read(page)
  elsif /imdb/ =~ u
    Imdb.read(page)
  elsif /tomato/ =~ u
    RottenTomato.read(u)
  end
end
