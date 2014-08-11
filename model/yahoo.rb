class Yahoo < Movie
  include Mongoid::Document
  include Mongoid::Timestamps
  
  @@review_url = "http://info.movies.yahoo.co.jp/userreview/tymv/"
  
  def read(page)
    Html.doc(page.url).css('b > a').each do |link|
      url = link['href']
      next unless /\/detail\/.*\/id.*\/$/ =~ url.to_s
      detail = Html.doc(url.to_s)
      self.title = detail.css('h3[itemprop="name"]').text
      self.mid = url.to_s.match(%r{\/id(.*)\/})[1]
    end
  end

  def set_reviews
    reviews = Review.set_reviews(self, @@review_url, self.mid)
  end
end
