class Article < ApplicationRecord
  validates :title, presence:true
  validates :contents, presence: true

  def self.getArticles(isMember = false)
    if (isMember)
      Article.all
    else
      Article.where(memberOnly: false)
    end
  end
end
