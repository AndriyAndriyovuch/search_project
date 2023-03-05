class IndexController < ApplicationController
  DATA_HASH = JSON.parse(File.read('config/languages.json'))
  def search
    return unless params[:query].present?

    if params[:match] == '1'
      params[:negative] == '1' ? exact_negative_match : exact_match
    else
      params[:negative] == '1' ? regular_negative_match : regular_match
    end

    sort_by_relevance unless params[:negative] == '1'
  end

  private

  def exact_match
    query_data = params[:query].downcase

    # collect all results by join json values to string and find if any value include string
    @results = DATA_HASH.select do |result|
      results_string = result.values.map(&:downcase).join(' ') # map all values into string
      result if results_string.include? query_data
    end
  end

  def regular_match
    # Split query text to match with every single word
    query_data = params[:query].downcase.split

    # Iterate every query word to search in data
    query_data.each do |word|
      @results = DATA_HASH.select do |result|
        results_string = result.values.map(&:downcase).join(' ') # map all values into string
        result if results_string.include? word
      end
    end
    @results
  end

  def exact_negative_match
    query_data = params[:query].downcase
    @results = DATA_HASH

    # delete result from results if there is exact match
    @results.delete_if { |result| result.values.map(&:downcase).join(' ').include? query_data }
  end

  def regular_negative_match
    @results = DATA_HASH

    # Split query text to match with every single word
    query_data = params[:query].downcase.split

    # Iterate every query word to search in data and delete from results if word matches
    query_data.each do |word|
      @results.delete_if { |result| result.values.map(&:downcase).join(' ').include? word }
    end
  end

  def sort_by_relevance
    # Compare length of query and data
    @results.map do |result|
      result['relevance'] = (result.values.map(&:downcase).join(' ').length - params[:query].length).to_s
    end

    # Sort by relevance and delete relevence field after it (only in positive search)
    @results.sort_by! { |result| result['relevance'].to_i }
    @results.map { |result| result.delete('relevance') }
  end
end
