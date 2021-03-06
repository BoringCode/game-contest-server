class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :contest
  belongs_to :programming_language

  has_many :player_matches, dependent: :restrict_with_error
  has_many :matches, through: :player_matches
  has_many :player_tournaments
  has_many :tournaments, through: :player_tournaments
  has_many :player_rounds
  has_many :rounds, through: :player_rounds

  validates :user,          presence: true
  validates :contest,       presence: true
  validates :description,   presence: true
  validates :name,          presence: true, uniqueness: { scope: :contest }
  #  validates :programming_language, presence: true

  include Uploadable
  def self.search(search)
    if search
      where('name LIKE ?', "%#{search}%")
    else
      all
    end
  end

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  def slug_candidates
	[
	  :name,
	  [:name, :contest_id]
	]
  end
  after_validation :move_friendly_id_error_to_name

  def move_friendly_id_error_to_name
    errors.add :name, *errors.delete(:friendly_id) if errors[:friendly_id].present?
  end
end
