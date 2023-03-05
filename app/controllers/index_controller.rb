class IndexController < ApplicationController
  DATA_HASH = JSON.parse(File.read('config/languages.json'))
  def search
    return unless params[:query].present?

    params[:match] == '1' ? exact_match : regular_match
  end

  private

  def exact_match
    query_data = params[:query].downcase

    # collect all results by join json values to string and find if any value include string
    @results = DATA_HASH.select do |data|
      case params[:negative] # Negative search
      when '1'
        data unless data.values.map(&:downcase).join(' ').include? query_data
      else
        data if data.values.map(&:downcase).join(' ').include? query_data
      end
    end
  end

  def regular_match
    query_data = params[:query].downcase.split # Split query text to match with every single word

    query_data.each do |word| # Iterate every query word to search in data
      @results = DATA_HASH.select do |data|
        case params[:negative] # Negative search
        when '1'
          data unless data.values.map(&:downcase).join(' ').include? word # map values into a string and search matches
        else
          data if data.values.map(&:downcase).join(' ').include? word
        end
      end
    end
  end
end
