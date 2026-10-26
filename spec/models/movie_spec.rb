require 'rails_helper'
require 'spec_helper'

describe Movie do
  describe 'searching Tmdb by keyword' do
    it 'calls Faraday gem' do
      expect(Faraday).to receive(:get)
      Movie.find_in_tmdb({title: 'hacker', language: 'en'})
    end

    it 'calls Tmdb with valid API key' do
      Movie.find_in_tmdb({title: "hacker", language: "en"})
    end

    it 'sends the title, year and API key to TMDb' do
      Movie.find_in_tmdb({title: 'Olympics', release_year: '2000', language: 'all'}, 'my_key')
      expect(a_request(:get, /api.themoviedb.org/).with { |req|
        q = req.uri.query_values
        q['query'] == 'Olympics' && q['year'] == '2000' && q['api_key'] == 'my_key'
      }).to have_been_made
    end

    it 'leaves out the year when it is blank' do
      Movie.find_in_tmdb({title: 'Olympics', release_year: '', language: 'all'}, 'my_key')
      expect(a_request(:get, /api.themoviedb.org/).with { |req|
        !req.uri.query_values.key?('year')
      }).to have_been_made
    end

    it 'returns unsaved Movie objects built from the results' do
      movies = Movie.find_in_tmdb({title: 'Olympics', release_year: '2000', language: 'all'})
      expect(movies.length).to eq(2)
      expect(movies).to all(be_a(Movie))
      expect(movies.first.title).to eq('Sydney 2000 Olympics Opening Ceremony')
      expect(movies.first.rating).to eq('R')
      expect(movies.first).to be_new_record
    end

    it 'returns an empty list when no movies match' do
      stub_request(:get, /api.themoviedb.org/).
        to_return(status: 200, body: '{"page":1,"results":[],"total_pages":0,"total_results":0}')
      expect(Movie.find_in_tmdb({title: 'zzzzzz', language: 'all'})).to eq([])
    end

    it 'returns an empty list when the API key is invalid' do
      stub_request(:get, /api.themoviedb.org/).
        to_return(status: 401, body: '{"status_code":7,"status_message":"Invalid API key","success":false}')
      expect(Movie.find_in_tmdb({title: 'hacker', language: 'all'}, 'bad_key')).to eq([])
    end
  end
end
