require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    @start_time = Time.now
  end

  def score
    end_time = Time.now
    answer = params[:answer]
    letters = params[:letters].split(' ')
    start_time = params[:start_time].to_time

    @result = { time: end_time - start_time }

    score_and_message = score_and_message(answer, letters, @result[:time])
    @result[:score] = score_and_message.first
    @result[:message] = score_and_message.last
    @result[:answer] = answer
    @result[:letters] = letters

  end




  private

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def english_word?(word)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end
end
