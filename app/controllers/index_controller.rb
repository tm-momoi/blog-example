class IndexController < ApplicationController

  def index
    @articles = Article.getArticles(signed_in?)
  end

end
