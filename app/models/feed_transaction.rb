class FeedTransaction < ActiveRecord::Base

  attr_accessible :identifier, :state

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
      in: [ :running, :complete, :successful, :has_failures ]
    }

  def state
    res = read_attribute(:state)
    res and res.to_sym
  end

end
