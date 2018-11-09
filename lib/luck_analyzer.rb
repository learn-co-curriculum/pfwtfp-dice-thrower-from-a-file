require 'csv'

class LuckAnalyzer
  attr_reader :csv_data

  def initialize(file_name)
    raise ArgumentError.new("Expected a String with ending .csv") unless file_name.end_with?(".csv")
    file_path = File.join(File.dirname(__FILE__), *['..', file_name])
    @csv_data = CSV.read(file_path)
  end

  def name_to_trials_count
    csv_data.reduce(Hash.new(0)) do |memo, row|
      memo[row[1]] += 1
      memo # always return the memo!
    end
  end

  def least_trials_slice
    name_to_trials_count.min_by{ |pair| pair[1] }
  end

  def most_trials_slice
    name_to_trials_count.max_by{ |pair| pair[1] }
  end

  def common_number_of_trials
    least_trials_slice.last
  end

  def least_trials_candidate
    least_trials_slice.first
  end

  def most_trials_candidate
    most_trials_slice.first
  end

  def create_dice_roll(max_pips, summary)
    die_values = summary.split(',').map(&:to_i)
    DiceRoller.new(die_values.length, max_pips, die_values)
  end

  def name_to_dice_rolls
    csv_data.reduce(Hash.new([])) do |memo, row|
      memo[row[1]] += [ create_dice_roll(row[2], row[3]) ]
      memo
    end
  end

  def name_to_rolls_lucky_status
    name_to_dice_rolls.reduce({}) do |memo, pair|
      memo[pair[0]] = pair[1].map(&:lucky?)
      memo
    end
  end

  def name_to_luck_percentages
    name_to_rolls_lucky_status.reduce({}) do |memo, pair|
      lucky_count = pair.last.select{|x| x}.length
      memo[pair.first] = lucky_count / Float(common_number_of_trials) * 100
      memo
    end
  end

  def luckiest
    luckiest_c = name_to_luck_percentages.max_by{ |e| e.last }
    return "#{luckiest_c[0]} (#{luckiest_c[1].round})"
  end
end
