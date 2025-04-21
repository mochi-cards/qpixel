xml.instruct! :xml, version: '1.0'
xml.feed xmlns: 'http://www.w3.org/2005/Atom' do
  xml.id index_feed_url
  xml.title "New Posts - All categories - #{SiteSetting['SiteName']}"
  xml.author do
    xml.name "#{SiteSetting['SiteName']}"
  end
  xml.link nil, rel: 'self', href: root_url
  xml.updated @posts.maximum(:last_activity)&.iso8601 || RequestContext.community.created_at&.iso8601

  xml << render('feed', posts: @posts, builder: xml)
end

