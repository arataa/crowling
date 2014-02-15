class Yahoo
  @@review_url = "http://info.movies.yahoo.co.jp/userreview/tymv/"
  
  def initialize(page)
    Html.doc(page.url).css('b > a').each do |link|
      url = link['href']
      next unless /\/detail\/.*\/id.*\/$/ =~ url.to_s
      detail = Html.doc(url.to_s)
      @title = detail.css('h3[itemprop="name"]').text
      @id = url.to_s.match(%r{\/id(.*)\/})[1]
    end
  end

  def reviews
    Anemone.crawl("#{@@review_url}id#{@id}/") do |anemone|
      anemone.on_every_page do |page| 
        rev = Html.doc(page.url.to_s)
        p page.url.to_s
        p rev.css('p.rev[itemprop="reviewBody"]').text
      end

    end
  end

end
