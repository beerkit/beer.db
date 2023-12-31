xml.instruct!
xml.comment! "#{app_title} Feed"
xml.feed xmlns: "http://www.w3.org/2005/Atom" do
  xml.title app_title()
  xml.subtitle app_subtitle()
  xml.link href: feed_url(), rel: 'self'
  xml.link href: root_url(), rel: 'alternate'
  xml.id root_url()
  xml.updated @today.iso8601
  xml.author do
    xml.name "#{app_title} Service"
  end
  @days.each do |day|
    xml.entry do
      xml.title "##{day.date.yday} - #{beer_headline(day.beer)}"
      xml.link href: page_url( date: day.date.strftime('%Y-%m-%d') ), rel: 'alternate'
      xml.id "tag:beer.db:#{day.beer.key}"
      xml.updated day.date.iso8601
      xml.content h(render(partial: 'shared/beer', locals: { beer: day.beer })), type: 'html'
    end
  end
end
