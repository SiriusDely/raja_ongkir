require 'test_helper'

describe RajaOngkir::Client do
  before do
    @raja_ongkir = RajaOngkir::Client.new ENV['API_KEY']
  end

  describe 'when asked about cities' do
    it 'must return all cities' do
      cities = @raja_ongkir.cities
      cities.must_be_instance_of Array
      cities.wont_be_empty
      cities.first['city_name'].must_be_instance_of String
    end
  end

  describe 'when asked to reload' do
    it 'must reload/refresh the cities' do
      cities = @raja_ongkir.cities
      cities.must_be_same_as @raja_ongkir.cities
      reloaded = @raja_ongkir.cities reload: true
      cities.must_equal reloaded
      cities.wont_be_same_as reloaded
    end
  end
end
