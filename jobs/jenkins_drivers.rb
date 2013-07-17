require 'httparty'
require 'nokogiri'

JENKINS_URI = "https://jenkins.10gen.com"
JENKINS_TITLE = "jenkins_projectstatus"
JENKINS_INTERVAL = '120s'
JENKINS_ATTRS = %i(S W Name Last_Success Last_Failure Last_Duration)
JENKINS_W_INDEX = JENKINS_ATTRS.index(:W)
JENKINS_PROJECTS = %w[
  mongo-c-driver              c
  mongo-csharp-driver-1.8x    csharp
  mongo-java-driver           java
  mongo-perl-driver           perl
  mongo-php-driver            php
  mongo-python-driver         python
  mongo-ruby-driver           ruby
  node-mongodb-native         node
].each_slice(2).to_a

def get_jenkins_projectstatus_all
  response = HTTParty.get(JENKINS_URI)
  doc = Nokogiri::HTML(response.body)
  projectstatus = doc.css('table#projectstatus > tr').map{|tr|
    td = tr.css('> td')
    if tr['id']
      h = Hash[*(JENKINS_ATTRS.each_with_index.map{|sym,index| [sym, td[index]['data'] || td[index].text.strip]}).flatten]
      img = td[JENKINS_W_INDEX].css('> a > img').first
      h[:W] = img && "#{JENKINS_URI}:#{img['src']}"
      h
    else
      nil
    end
  }.compact
  Hash[*(projectstatus.map{|element| [element[:Name], element] }.flatten(1))]
end

if $0 =~ /thin/
  SCHEDULER.every JENKINS_INTERVAL, :first_in => 0 do |job|
    status = get_jenkins_projectstatus_all
    JENKINS_PROJECTS.each do |project_name, image_name|
      send_event(project_name, status[project_name].merge({:image => "#{image_name}-256.png"}))
    end
  end
else
  require 'test/unit'

  class JenkinsJobTest < Test::Unit::TestCase
    test "get_jenkins_projectstatus_all" do
      status = get_jenkins_projectstatus_all
      JENKINS_PROJECTS.each do |project_name, image_name|
        p [project_name, status[project_name].merge({:image => "#{image_name}-256.png"})]
      end
    end
  end
end
