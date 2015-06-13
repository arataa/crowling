require_relative "movie.rb"
class Imdb < Movie
  include Mongoid::Document
  include Mongoid::Timestamps
  
  @@review_url = "http://cinema.pia.co.jp/imp/"

  def self.read(page)
    Html.doc(page.url).css('div.list_item').each do |movie|
      title = movie.css('h4[itemprop="name"]').text.gsub(/- \[Limited\]/,"").gsub(/\([0-9]...\)/,"").strip
      description = movie.css("div.outline").text
      director = movie.css("span[itemprop='director'] span[itemprop='name']").first.text.gsub(/\n/,"").strip
      actors = movie.css("span[itemprop='actors']").map{|a| a.text.gsub(/\n/,"").strip}
      mid = movie.css('h4[itemprop="name"] a').attr("href").value.scan(/tt([0-9].*)\//).flatten.first.to_i
      unless Movie.where(mid_imdb: mid).first
        obj = Movie.new
        obj.title = title
        obj.description = description
        obj.director = director
        obj.mid_imdb = mid
        actors.each{|a| obj.actors.build name: a}
        obj.save!
      else
        obj = Movie.find_by(mid_imdb: mid)
        obj.update title: title, description: description, director: director
      end
    end
    
    #doc.css('h1 strong').each do |title|
    #  p title.inner_text().encoding
    #end
    #p page.url
    #p page.doc.xpath("//head/title/text()").first.to_s if page.doc
    #p page.body[0..200]
  end
  
  def self.reviews(obj)
  end

end
