class FeedTransaction < ActiveRecord::Base

  States = [ :running, :complete, :successful, :failed, :has_failures ]

  attr_accessible :identifier, :state, :failure

  has_many :tasks, class_name: 'FeedTask', foreign_key: :transaction_id

  validates :identifier,
    presence: true,
    numericality: {
      integer_only: true,
      greater_than: 0
    },
    uniqueness: true

  validates :state,
    presence: true,
    inclusion: {
      in: States
    }

  States.each do | state |
    scope state, -> { where state: state }
  end

  def state
    res = read_attribute(:state)
    res and res.to_sym
  end

end
