require 'rails_helper'

describe Movie do
  describe 'searching Tmdb for movies already in RottenPotatoes' do
    it 'leaves out movies that are already saved in the database' do
      Movie.create!(title: 'Sydney 2000 Olympics Opening Ceremony', rating: 'R',
                    release_date: '2000-09-15')
      movies = Movie.find_in_tmdb({title: 'Olympics', release_year: '2000', language: 'all'})
      expect(movies.map(&:title)).to eq(['Sydney 2000 Olympics Closing Ceremony'])
    end

    it 'keeps a movie with the same title but a different release date' do
      Movie.create!(title: 'Sydney 2000 Olympics Opening Ceremony', rating: 'R',
                    release_date: '1999-01-01')
      movies = Movie.find_in_tmdb({title: 'Olympics', release_year: '2000', language: 'all'})
      expect(movies.length).to eq(2)
    end
  end
end
