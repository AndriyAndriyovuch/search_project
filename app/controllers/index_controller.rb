class IndexController < ApplicationController
  def search
    data_hash = JSON.parse(File.read('config/languages.json'))

    if params[:query].present?
      query_data = params[:query].downcase

      #collect all results by join json values to string and find if any value include string
      @results = data_hash.select do | data |
        data if data.values.map { | key | key.downcase }.join(' ').include? query_data
      end
    end
  end
end
