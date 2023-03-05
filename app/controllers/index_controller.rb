class IndexController < ApplicationController
  DATA_HASH = JSON.parse(File.read('config/languages.json'))
  def search
    if params[:query].present?
      params[:match] == '1' ? exact_match : regular_match
    end


  end

  private
  def exact_match
    query_data = params[:query].downcase

    #collect all results by join json values to string and find if any value include string
    @results = DATA_HASH.select do | data |
      data if data.values.map { | key | key.downcase }.join(' ').include? query_data
    end
  end

  def regular_match
    query_data = params[:query].downcase.split(' ') # Split query text to match with every single word

    query_data.each do | word | # Iterate every query word to search in data
      @results = DATA_HASH.select do | data |
        data if data.values.map { | key | key.downcase }.join(' ').include? word # map all values into a string and search matches
      end
    end
  end
end
