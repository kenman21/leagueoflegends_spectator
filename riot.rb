require 'rest-client'
require 'json'
require 'pry'
require 'fileutils'


#api_key: RGAPI-899cd0c9-ee00-40e5-8821-448dd26260fe

class Summoner

  attr_accessor :current_game_key, :gameID

  @@keys = []

  def initialize(summoner_name)
    all_characters = RestClient.get("https://na1.api.riotgames.com/lol/summoner/v3/summoners/by-name/#{summoner_name}?api_key=RGAPI-899cd0c9-ee00-40e5-8821-448dd26260fe")
    summoner = JSON.parse(all_characters)
    @@keys = summoner.keys
    self.class.accessor
    summoner.each {|k,v| self.send("#{k}=", v)}
  end

  def self.accessor
    @@keys.each {|k| attr_accessor k.to_sym}
  end

  def is_playing?
    begin
    game = RestClient.get("https://na1.api.riotgames.com/lol/spectator/v3/active-games/by-summoner/#{id}?api_key=RGAPI-899cd0c9-ee00-40e5-8821-448dd26260fe")
    rescue RestClient::NotFound
      return "Summoner is not in a game."
    else
      game_info = JSON.parse(game)
    end
  end

  def get_current_game_info
    @gameID = is_playing?["gameId"]
    @current_game_key = is_playing?["observers"]["encryptionKey"]
  end

  def launch_spectator
    FileUtils.cd("../../../../")
    FileUtils.cd("/Applications/League of Legends.app/Contents/LoL/RADS/solutions/lol_game_client_sln/releases/0.0.1.28/deploy")
    system("open","'League of Legends.app' 8394 LoLLauncher.app '' 'spectator spectator.na.lol.riotgames.com:80 #{current_game_key} #{gameID} NA1'")
  end

end

binding.pry
