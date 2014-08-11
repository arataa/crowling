class Review
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :rid_yahoo, type: Integer
  field :rid_pia, type: Integer
  field :rating, type: Integer
  field :content, type: String
  field :datetime, type: DateTime

  embedded_in :movie

  def self.set_reviews(movie, url, id)
    Anemone.crawl("#{url}id#{id}/", depth_limit: 2) do |anemone|
      anemone.on_every_page do |page| 
        next unless /id#{id}/ =~ page.url.to_s
        next unless /\/rid.*\// =~ page.url.to_s
        next if /\?/ =~ page.url.to_s
        rev = Html.doc(page.url.to_s) rescue next ;
        d = self.get(rev, page.url.to_s)
        if movie.reviews.where(rid: d[:rid]).size == 0
          movie.reviews.create(d)
        else
          movie.reviews.find_by(rid: d[:rid]).update d
        end
      end
    end
  end

  def self.get(rev, url)
    d = {}
    d[:rid] = url.match(%r{\/rid(.*?)\/})[1].to_i
    d[:title] = rev.css('span[itemprop="name"]').text
    if rev.css('meta[itemprop="ratingValue"]').size == 1
      d[:rating] = rev.css('meta[itemprop="ratingValue"]').attr('content').value.to_i
    end
    d[:content] = rev.css('p.rev[itemprop="reviewBody"]').text
    d[:datetime] = Time.parse(rev.css('span[itemprop="datePublished"]').text)
    d
  end
end
