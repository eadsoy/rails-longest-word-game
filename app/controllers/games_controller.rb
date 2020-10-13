require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    gen_grid = [('A'..'Z')].map(&:to_a).flatten
    @letters = (0...10).map { gen_grid[rand(gen_grid.length)] }
    @letters
  end

  def score
    @word = params[:word].upcase
    @letters = params[:letters]
    @url = "https://wagon-dictionary.herokuapp.com/#{@word}"
    @dict = open(@url).read
    @get_word = JSON.parse(@dict)
    return unless @word.present?

    if @get_word.key? 'error'
      @answer = "Sorry but <strong>#{@word}</strong> doesn't seem to be a valid english word."
      @end_score = 0
    elsif @get_word.key? 'length'
      @answer = "<strong>Congratulations!</strong> #{@word} is a valid English word!"
      @end_score = @word.split('').length * 1000
    end
    @word.split('').each do |letter|
      if (@letters.include? letter) == false || (@letters.count(letter) < @word.chars.count(letter))
        @answer = "Sorry but <strong>#{@word}</strong> can't be build out of #{@letters.split(' ').join(', ')}."
        @end_score = 0
      end
    end
    # ActionDispatch::Session::CookieStore
    # session['scores'] << end_score
    session['end_score'] << [@end_score]
    @end_num = session['end_score'].last(5).flatten
    # session['scores'] += end_score
  end
end
