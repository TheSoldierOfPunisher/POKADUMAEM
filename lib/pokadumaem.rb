# frozen_string_literal: true

require_relative "pokadumaem/version"
require 'csv'

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

# Пример использования
begin
  # Считывание данных о футбольной статистике по странам
  country_stats_data = read_country_stats('AllTimeRankingByCountry.csv')

  # Получение объекта страны
  country = country_stats_data.find_country('Spain')

  # Вывод метрик
  puts "Статистика для #{country.name}:"
  puts "--------------------------------"
  puts "Всего матчей: #{country.played}"
  puts "Всего голов: #{country.goals_for}"
  puts "Победы: #{country.wins}"
  puts "Среднее голов за матч: #{country.average_goals_per_game}"
  puts "Процент побед (win rate): #{country.win_rate}%"
  puts "Разница голов: #{country.goal_diff}"
  puts "Индекс эффективности: #{country.efficiency_index}%"
  puts "Титулы: #{country.titles}"

  # Связь между количеством титулов и win-rate
  title_winrate_ratio = country.titles.to_f / country.win_rate if country.win_rate > 0
  puts "Соотношение титулов к win-rate: #{title_winrate_ratio.round(4)}" unless title_winrate_ratio.nil?

  # Топ страны по различным метрикам
  top_by_titles = country_stats_data.top_by_titles
  puts "\nСтрана с наибольшим количеством титулов: #{top_by_titles.name} (#{top_by_titles.titles})"

  most_winning_country = country_stats_data.top_by_win_rate
  puts "Страна с наивысшим win-rate: #{most_winning_country.name} (#{most_winning_country.win_rate}%)"

  most_efficient_country = country_stats_data.most_efficient
  puts "Самая эффективная команда: #{most_efficient_country.name} (индекс #{most_efficient_country.efficiency_index}%)"
rescue Errno::ENOENT
  puts "Файл не найден. Пожалуйста, проверьте путь к файлу."
rescue => e
  puts "Произошла ошибка: #{e.message}"
end
end
