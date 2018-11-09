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

  def common_number_of_trials
    least_trials_slice.last
  end

  def least_trials_candidate
    least_trials_slice.first
  end

  def most_trials_candidate
    name_to_trials_count.max_by{ |pair| pair[1] }[0]
  end

  def luckiest
    name_to_trials = {}
    name_to_lucky_percentages = {}

    csv_data.each do |row|
      name = row[1]
      if !name_to_trials.has_key?(name)
        name_to_trials[name] = []
      end
      die_values = row[3].split(',')
      die_values_as_integers = die_values.map { |v| v.to_i }
      name_to_trials[name] << DiceRoller.new(die_values.length, row[2],die_values_as_integers).lucky?
    end

    name_to_trials.each_pair do |name, sets|
      lucky_count = sets.select{|x| x}.length
      name_to_lucky_percentages[name] = lucky_count / Float(common_number_of_trials) * 100
    end

    maximum_value = nil
    maximum_name = nil

    name_to_lucky_percentages.each_pair do |k, v|
      # Initialize to the first the first time around
      if maximum_value.nil? &&  maximum_name.nil?
        maximum_value = v
        maximum_name = k
      end

      if maximum_value < v
        maximum_value = v
        maximum_name = k
      end
    end

    return "#{maximum_name} (#{maximum_value.round})"
  end
end
