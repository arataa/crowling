class Pia < Movie
  include Mongoid::Document
  include Mongoid::Timestamps
  
  @@photo_url = "http://cinema.pia.co.jp/piaphoto/title/450/"
  @@review_url = "http://cinema.pia.co.jp/imp/"
  @@review_top_url = "http://cinema.pia.co.jp/"

  def self.read(page)
    Html.doc(page.url).css('ul.commonMovieList li').each do |movie|
      obj  = Movie.new
      link = movie.css('div')[1].css('p span a')

      obj.mid_pia = link.attr('href').to_s.gsub(/\//,"").gsub(/title/,"")
      if Movie.where(mid_pia: obj.mid_pia).first
        obj = Movie.where(mid_pia: obj.mid_pia).first
      end
      obj.title = link.text
      p obj.title

      obj.description = movie.css('div')[1].css('p').text
      d = movie.css('div')[2].css('p.jumpLink').text.scan(/(\d{4})年(\d{1,})月(\d{1,})日/).first
      next unless d
      obj.open_date = Date.new(d[0].to_i,d[1].to_i,d[2].to_i)

      html = movie.css('div')[2].inner_html.gsub(/\n/,"")
      info = html.scan(/監督.<\/strong>(.*)<br>.*出演.<\/strong>(.*)<br>.*配給/)
      next unless info.present?
      obj.director = info[0][0] if info.present?

      info[0][1].gsub(/\t/,"").split("、").each do |a|
        actor = Actor.where(name: a).first
        if actor
          actor.movie_ids << obj._id unless actor.movie_ids.include? obj._id
        else
          obj.actors.build(name: a)
        end
      end

      #画像
      url = @@photo_url + obj.mid_pia.to_s + "_1.jpg"
      obj.remote_image_url = url
      obj.save
      self.reviews(obj)
    end
  end
  
  def self.reviews(obj)
    url = @@review_url + obj.mid_pia.to_s + "/"
    Html.doc(url).css('#mainImpMain table tr').each do |r|
      t = r.css('a')
      next unless t.attr("title")
      tmp = Html.doc(@@review_top_url  + t.attr('href').value)
      title   = tmp.css(".commonPrevNextNavi h2").text
      rid_pia = t.attr('href').value.scan(/#{obj.mid_pia}\/(.*)\/$/).flatten.first
      rating  = tmp.css(".commonPostInfo img")[0].attr("alt").gsub(/点/,"").to_i
      time = tmp.css(".commonPostInfo").text.scan(/\w+/)
      datetime = Time.new(time[0], time[1], time[2], time[3], time[4])
      content = tmp.css("#mainImpEntry p")[2].text
      unless obj.reviews.where(rid: rid_pia).first
        obj.reviews.create(
          title: title, rid: rid_pia, rating: rating, datetime: datetime, content: content)
      end
    end
  end

end
