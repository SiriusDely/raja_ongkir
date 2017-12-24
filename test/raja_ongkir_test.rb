require 'test_helper'

class RajaOngkirTest < Minitest::Test
  def setup
    @raja_ongkir = RajaOngkir::Client.new ENV['API_KEY']
  end

  def test_that_it_has_a_version_number
    refute_nil ::RajaOngkir::VERSION
  end

  def test_that_it_return_provinces
    provinces = @raja_ongkir.provinces
    assert provinces.is_a?(Array)
    assert !provinces.empty?
    assert provinces.first['province'].is_a?(String)
  end

  def test_that_it_reloads_when_asked_to_reload
    provinces = @raja_ongkir.provinces
    provinces.pop
    reloaded = @raja_ongkir.provinces reload: true
    assert reloaded.length == provinces.length + 1
  end

  def test_that_given_keyword_it_returns_some_provinces
    q = 'Barat'
    west_provinces = @raja_ongkir.provinces q
    assert !west_provinces.empty?
    west_provinces.each do |w|
      assert w['province'].downcase.include?(q.downcase)
    end
  end

  def test_that_provinces_rejects_keyword_except_string
    assert_raises(RuntimeError) { @raja_ongkir.provinces 11 }
  end

  def test_that_it_returns_province_by_id
    province_id = 11
    province = @raja_ongkir.province province_id
    assert province['province_id'] == province_id.to_s
  end

  def test_that_province_rejects_id_except_integer
    assert_raises(RuntimeError) { @raja_ongkir.province '11' }
  end
end
