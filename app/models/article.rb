class Article < ApplicationRecord
  def self.getArticles(isMember = false)
    if (isMember)
      Article.all
    else
      Article.where(memberOnly: false)
    end
  end
end
