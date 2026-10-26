require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end

    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).
        with(hash_including(title: 'hardware', release_year: '1999', language: 'en')).
        and_return(@fake_results)
      get :search_tmdb, params: {title: 'hardware', release_year: '1999', language: 'en'}
    end

    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
        get :search_tmdb, params: {title: 'hardware', release_year: '', language: 'all'}
      end
      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end
      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end

    describe 'when the title is missing' do
      it 'does not call the model method' do
        expect(Movie).not_to receive(:find_in_tmdb)
        get :search_tmdb, params: {title: '', release_year: '1986', language: 'all'}
      end
      it 'shows the required fields error' do
        get :search_tmdb, params: {title: '', release_year: '1986', language: 'all'}
        expect(flash[:danger]).to eq('Please fill in all required fields!')
        expect(response).to render_template('search_tmdb')
      end
    end

    it 'shows an error when no movies are found' do
      allow(Movie).to receive(:find_in_tmdb).and_return([])
      get :search_tmdb, params: {title: 'zzzzzz', release_year: '', language: 'all'}
      expect(flash[:danger]).to eq('No movies found with given parameters!')
    end

    it 'shows no error on the first visit to the search page' do
      expect(Movie).not_to receive(:find_in_tmdb)
      get :search_tmdb
      expect(flash[:danger]).to be_nil
    end
  end

  describe 'adding a movie from TMDb' do
    before :each do
      @movie_params = {title: 'Hackers', rating: 'R', release_date: '1995-09-15',
                       description: 'A young hacker...'}
    end

    it 'saves the movie to the database' do
      expect { post :add_movie, params: @movie_params }.to change(Movie, :count).by(1)
      expect(Movie.last.title).to eq('Hackers')
    end

    it 'redirects to the search page with a success message' do
      post :add_movie, params: @movie_params
      expect(response).to redirect_to(search_tmdb_path)
      expect(flash[:success]).to eq('Hackers was successfully added to RottenPotatoes.')
    end
  end
end
