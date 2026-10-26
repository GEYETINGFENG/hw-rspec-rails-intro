require 'rails_helper'

describe Movie do
  describe 'searching Tmdb by keyword' do
    it 'calls Faraday gem with CS169 domain' do
      expect(Faraday).to receive(:get).with('https://cs169.org')
      Movie.find_in_tmdb('https://cs169.org')
    end
  end
end
