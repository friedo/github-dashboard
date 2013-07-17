require 'HTTParty'
require 'mongo'

class StatusReporter

  DB_NAME              = 'citibike'
  DB                   = Mongo::MongoClient.new[DB_NAME]
  STATIONS             = DB['stations']
  MONGODB_OFFICE_COORD = [-73.988179, 40.757468]
  BASE_URL             = 'https://citibikenyc.com'
  STATIONS.ensure_index( { 'geo' => '2dsphere' } )

  def nearby_statuses(station = nil)
    stations = fetch_data(stations_url)
    update_station_data(stations)
    nearest_station(MONGODB_OFFICE_COORD).map do |s|
      { :label => s['label'],
        :bikes_avail => "#{s['bikes_avail']} bike(s) / ",
        :docks_avail => "#{s['docks_avail']} dock(s)"
      }
    end
  end

  private

  def fetch_data(url)
    JSON.parse(HTTParty.get(url))['stationBeanList']
  end

  def update_station_data(stations)
    stations.each do |s|
      STATIONS.update({'_id' => s['id']},
        {'$set' =>
           {'geo' => {
                :type => 'Point',
                :coordinates => [s['longitude'].to_f,
                                 s['latitude'].to_f]
              },
           'label'        => s['stationName'],
           'status'       => s['statusValue'],
           'bikes_avail'  => s['availableBikes'],
           'docks_avail'  => s['availableDocks']}
        },
        :upsert => true)
    end
  end

  def nearest_station(coordindates)
    point = {
        'type' => 'Point',
        'coordinates' => coordindates
      }
    stations = STATIONS.find({'geo' =>
                        { '$near' => {'$geometry' => point} }
                      })
    stations.to_a[0..4]
  end

  def stations_url
    BASE_URL + '/stations/json/'
  end

end


SCHEDULER.every '1m' do
  reporter ||= StatusReporter.new
  send_event('citibike', { items: reporter.nearby_statuses })
end
