class WelcomeController < ApplicationController
  PER = 8

  def index
    @words = Word.page(params[:page]).per(PER)
  end
end