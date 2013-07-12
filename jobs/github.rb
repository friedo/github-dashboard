require 'httparty'

class GitHub
    include HTTParty
    format :json
end

repos = [ 'mongodb/mongo', 
          'mongodb/mongo-ruby-driver', 
          'mongodb/mongo-perl-driver', 
          'mongodb/mongo-python-driver',
          'mongodb/mongo-java-driver', 
          'mongodb/mongo-csharp-driver',
          'mongodb/mongo-c-driver',
          'mongodb/mongo-php-driver',
        ] 

SCHEDULER.every '10s' do

    # auth token for github
    token = IO.read( ".token" );

    for repo in repos
        res = GitHub.get( 
            "https://api.github.com/repos/#{repo}/commits",
            :headers => { 
                "Authorization" => "token #{token}"
        })

        commits = res[0..9]
        commits = commits.map{ |i| { :label => i['commit']['tree']['sha'][ 32, 40 ], :value => i['commit']['message'][ 0, 64 ] + '...' } }
        send_event( "github-#{repo}", { items: commits } )
    end
end
