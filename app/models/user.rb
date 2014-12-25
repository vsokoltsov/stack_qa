class User <ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :questions
  has_many :answers

  validates :email, :password, presence: true
  validates :email, uniqueness: true

  devise :database_authenticatable, :registerable, :confirmable, :recoverable, stretches: 20
end