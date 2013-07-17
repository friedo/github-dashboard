require 'travis'

def update_builds(repository, config, data_id)
  builds = []
  repo = nil
  repo = Travis::Repository.find(repository)
  
  build = nil

  if data_id.end_with?('pr')
    build = repo.builds.detect {|b| b.pull_request? }
  else
    build = repo.builds.detect {|b| b.branch_info == "master" }
  end

  build ||= repo.last_build

  if build
    build_info = {
      label: "#{build.branch_info}",
      state: build.state
    }
  else
    build_info = { label: "unknown", state: "unknown" }
  end
  builds << build_info

  builds
end

config_file = File.dirname(File.expand_path(__FILE__)) + '/../config/travisci.yml'
config = YAML::load(File.open(config_file))

SCHEDULER.every('10m', first_in: '1s') {
  config.each do |type, type_config|
    unless type_config["repositories"].nil?
      type_config["repositories"].each do |data_id, repo|
        send_event(data_id, { items: update_builds(repo, type_config, data_id) })
      end
    else
      puts "No repositories for travis.#{type}"
    end
  end
}
