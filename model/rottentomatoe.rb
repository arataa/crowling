require_relative "movie.rb"
class RottenTomato < Movie
  include Mongoid::Document
  include Mongoid::Timestamps
  
  def self.read(page)
    (1..10).each do |i|
      list = Html.doc(page.url.to_s + "?page=#{i}")
      break if list.css('div.movie_item').size == 0
      list.css('div.movie_item').each do |movie|
        obj = Movie.new
        obj.title = movie.css('h2 a').text
        p obj.title
        url = "http://www.rottentomatoes.com/" + movie.css('h2 a').attr("href").to_s
        begin
          detail = Html.doc(url)
        rescue
          retry
        end
        obj.description = detail.css('#movieSynopsis').text.gsub(/\n/,"").gsub(/\t/,"")
        obj.director = detail.css("p[itemprop='director'] span[itemprop='name']").text
        actors = detail.css("li[itemprop='actors'] span[itemprop='name']").map{|a| a.text}
        obj.mid_tomato = detail.css("#movie_rating_widget").attr("data-media-id").to_s.to_i
        obj.open_date = detail.css('span[itemprop="datePublished"]').text

        exist_obj = Movie.where(mid_tomato: obj.mid_tomato).first
        unless exist_obj
          actors.each{|a| obj.actors.build name: a}
          obj.save
        else
          obj = exist_obj
        end
        #画像
        image_url = detail.css('div.movie_poster_area img').attr('src').to_s
        begin
          obj.image = open(image_url)
          obj.save
        rescue
        end

        self.reviews obj, url, obj.mid_tomato
      end
    end
  end
  
  def self.reviews(obj, url, mid)
    begin rev = Html.doc(url + "/reviews/?type=user") rescue retry end
    rid_tomato = nil
    pre_rid_tomato = nil
    (2..100).each do |i|
      pre_rid_tomato = rid_tomato
      rev.css("#reviews .media_block.bottom_divider").each do |r|
        content = r.css(".user_review").text.gsub(/\n/,"").gsub(/\t/,"")
        datetime = r.css(".fr.small.subtle").text
        rid_tomato = r.css("a")[0].attr("href").scan(/.*id\/(.*)\//).join.to_i
        break if rid_tomato == pre_rid_tomato
        rating = r.css("span.rating").attr("class").to_s.scan(/score(.*)/).join.to_i

        unless obj.reviews.where(rid: rid_tomato).first
          obj.reviews.create(
            rid: rid_tomato, rating: rating, datetime: datetime, content: content)
        end
      end
      break unless rid_tomato
      break if rev.css("#reviews .media_block.bottom_divider").size == 0

      begin
        rev = Html.doc(url + "/reviews/?page=#{i}&type=user")
      rescue
        retry
      end
    end
  end

end
