class Match
  attr_reader :home_team, :away_team, :result

  def initialize(home_team, away_team)
    @home_team = home_team
    @away_team = away_team
  end

  def set_result(result)
    @result = result
  end
end