# frozen_string_literal: true

require_relative "pokadumaem/version"
require 'csv'
require 'date'

module Pokadumaem
  class Error < StandardError; end
  
  class CountryStats
  attr_reader :name, :participated, :titles, :played, :win, :draw, :loss, 
              :goals_for, :goals_against, :pts, :goal_diff

  def initialize(row)
    @name = row['Country']
    @participated = row['Participated'].to_i
    @titles = row['Titles'].to_i
    @played = row['Played'].to_i
    @win = row['Win'].to_i
    @draw = row['Draw'].to_i
    @loss = row['Loss'].to_i
    @goals_for = row['Goals For'].to_i
    @goals_against = row['Goals Against'].to_i
    @pts = row['Pts'].to_i
    @goal_diff = row['Goal Diff'].to_i
  end

  # Общее количество сыгранных матчей
  def played
    @played
  end

  # Общее количество забитых голов
  def goals_for
    @goals_for
  end

  # Количество побед
  def wins
    @win
  end

  # Среднее количество голов за матч
  def average_goals_per_game
    return 0 if @played.zero?
    (@goals_for.to_f / @played).round(2)
  end

  # Процент побед (win rate)
  def win_rate
    return 0 if @played.zero?
    (@win.to_f / @played * 100).round(2)
  end

  # Разница голов
  def goal_diff
    @goal_diff
  end

  # Индекс эффективности (учитывая победы и ничьи)
  def efficiency_index
    return 0 if @played.zero?
    ((@win * 3 + @draw).to_f / (@played * 3) * 100).round(2)
  end
end

class CountryStatsData
  def initialize(countries)
    @countries = countries
  end

  def find_country(name)
    @countries.find { |c| c.name == name }
  end

  # Страна с наибольшим количеством титулов
  def top_by_titles
    @countries.max_by(&:titles)
  end

  # Страна с наибольшим win-rate
  def top_by_win_rate
    @countries.max_by(&:win_rate)
  end

  # Самая эффективная команда (по индексу эффективности)
  def most_efficient
    @countries.max_by(&:efficiency_index)
  end
end

def read_country_stats(file_path)
  countries = []
  
  CSV.foreach(file_path, headers: true) do |row|
    countries << CountryStats.new(row)
  end

  CountryStatsData.new(countries)
end

end
