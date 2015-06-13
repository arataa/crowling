require_relative "movie.rb"
class RottenTomato < Movie
  include Mongoid::Document
  include Mongoid::Timestamps
  
  def self.read(url)
    #(1..10).each do |i|
    p url
    Capybara.register_driver :poltergeist do |app| 
      Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 1000 })
    end
    Capybara.default_selector = :css
    session = Capybara::Session.new(:poltergeist)
    session.visit url
    list = Nokogiri::HTML.parse(session.html)
    #list = Html.doc(page.url.to_s) rescue return
    
    return if list.css('div.mb-movie').size == 0
    list.css('div.mb-movie').each do |movie|
      obj = Movie.new
      obj.title = movie.css('h3').text
      p obj.title
      url = "http://www.rottentomatoes.com/" + movie.css('.poster_container a').attr("href").to_s
      begin
        detail = Html.doc(url)
      rescue
        retry
      end
      obj.description = detail.css('#movieSynopsis > text()').text.gsub(/\n/,"").gsub(/\t/,"").gsub(/<+>/,'')
      obj.director = detail.css("td[itemprop='director'] span[itemprop='name']").text
      actors = detail.css(".cast-item span[itemprop='name']").map{|a| a.text}
      obj.mid_tomato = detail.css("#rating_widget").attr("data-media-id").to_s.to_i
      obj.open_date = detail.css('td[itemprop="datePublished"]').text

      exist_obj = Movie.where(mid_tomato: obj.mid_tomato).first
      unless exist_obj
        actors.each{|a| obj.actors.build name: a}
        obj.save
      else
        [:title, :description, :director, :open_date].each do |e|
          exist_obj.send("#{e}=",obj.send(e))
        end
        obj = exist_obj
        obj.save
      end
      #画像
      image_url = detail.css('img.posterImage').attr('src').to_s
      begin
        obj.image = open(image_url)
        obj.save
      rescue
      end

      self.reviews obj, url, obj.mid_tomato
    end
  end
  
  def self.reviews(obj, url, mid)
    begin rev = Html.doc(url + "/reviews/") rescue retry end
    rid_tomato = nil
    pre_rid_tomato = nil
    (2..100).each do |i|
      pre_rid_tomato = rid_tomato
      rev.css("#reviews .review_table_row").each do |r|
        content = r.css(".the_review").text.gsub(/\n/,"").gsub(/\t/,"")
        datetime = r.css(".review_date").text
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
