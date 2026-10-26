class Movie < ActiveRecord::Base
  TMDB_SEARCH_URL = 'https://api.themoviedb.org/3/search/movie'.freeze

  # search_params: { title: 'Manhunter', release_year: '1986', language: 'en' or 'all' }
  # Returns Movie objects that are NOT saved to the database.
  def self.find_in_tmdb(search_params, api_key = ENV.fetch('TMDB_API_KEY', ''))
    query = { api_key: api_key, query: search_params[:title] }
    query[:year] = search_params[:release_year] if search_params[:release_year].present?
    english_only = search_params[:language] == 'en'
    query[:language] = 'en-US' if english_only

    response = Faraday.get(TMDB_SEARCH_URL, query)
    return [] unless response.respond_to?(:status) && response.status == 200

    results = JSON.parse(response.body)['results'] || []
    results = results.select { |m| m['original_language'] == 'en' } if english_only
    movies = results.map do |m|
      Movie.new(title: m['title'], release_date: m['release_date'],
                rating: 'R', description: m['overview'])
    end
    # leave out movies that are already saved in RottenPotatoes
    movies.reject { |movie| Movie.exists?(title: movie.title, release_date: movie.release_date) }
  end

  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end
end
