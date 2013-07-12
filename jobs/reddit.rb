require 'net/http'
require 'json'

class Reddit
  def initialize()
    # add your desired subreddits here
    @subreddits = {
      '/r/mongodb' => 'http://www.reddit.com/r/mongodb.json',
    }

    # the limit per subreddit to grab
    @maxcount = 5
  end

  def getTopPostsPerSubreddit()
    posts = [];

    @subreddits.each do |subreddit, url|
      response = JSON.parse(Net::HTTP.get(URI(url)))

      if !response
        puts "reddit communication error for #{@subreddit} (shrug)"
      else
        items = []

        for i in 0..@maxcount
          title = response['data']['children'][i]['data']['title']
          trimmed_title = title[0..85].gsub(/\s\w+$/, '...')

          items.push({
            title: trimmed_title,
            score: response['data']['children'][i]['data']['score'],
            comments: response['data']['children'][i]['data']['num_comments']
          })
        end

        posts.push({ label: 'Current top posts in "' + subreddit + '"', items: items })
      end
    end

    posts
  end
end

@Reddit = Reddit.new();

SCHEDULER.every '5m', :first_in => 0 do |job|
  posts = @Reddit.getTopPostsPerSubreddit
  send_event('reddit', { :posts => posts })
end
