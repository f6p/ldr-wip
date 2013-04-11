atom_feed :root_url => news_index_url do |feed|
  feed.title 'Recent News'
  feed.updated @news.first.created_at unless @news.size.zero?

  @news.each do |news|
    feed.entry(news) do |entry|
      entry.title news.title
      entry.content textile(news.body), :type => 'html'
    end
  end
end
