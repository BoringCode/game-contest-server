class PlayerTournament < ActiveRecord::Base
  belongs_to :player
  belongs_to :tournament, inverse_of: :player_tournaments

  validates :player, presence: true
  validates :tournament, presence: true
	
	default_scope -> { order("player_tournaments.updated_at DESC") }
end
