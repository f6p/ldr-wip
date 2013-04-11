atom_feed :root_url => games_url do |feed|
  feed.title 'Game History'
  feed.updated @games.first.created_at unless @games.size.zero?

  @games.each do |game|
    feed.entry(game) do |entry|
      entry.title game_feed_title game
    end
  end
end
