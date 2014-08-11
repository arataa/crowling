class Html
  def self.doc url
    html = open(url).read.encode("utf-8", :invalid => :replace, :undef => :replace)
    Nokogiri::HTML.parse(html, nil, "UTF-8")
  end
end
