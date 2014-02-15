# -- coding: utf-8

class Pia
  def initialize(page)
    charset = nil
    html = open(page.url).read.encode("utf-8", :invalid => :replace, :undef => :replace)
    doc = Nokogiri::HTML.parse(html, nil, "UTF-8")
    p doc.title
    
    doc.css('a').each do |link|
      #url = link.attr("href")
      url = link['href']
      next unless /\/detail\/.*\/id.*\/$/ =~ url
      detail = Nokogiri::HTML.parse(open(url), nil, "UTF-8")
      p Kconv.toutf8(detail.title) 
      p Kconv.toutf8(detail.css('h3[itemprop="name"]').text)
      p detail.css('h3[itemprop="name"]').text
    end
  end
end
