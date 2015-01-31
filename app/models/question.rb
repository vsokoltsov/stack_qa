class Question < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  has_many :answers
  has_many :comments, as: :commentable
  validates :title, :text, presence: true
  validates :title, uniqueness: true
end