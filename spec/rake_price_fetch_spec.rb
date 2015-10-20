require 'rspec'
require 'spec_helper'
require 'rails_helper'
require 'nokogiri'
require 'pry-byebug'
require 'rake'

describe 'rproxy, webscrape, countdown homepage' do
  before do
    require "#{Rails.root}/lib/modules/countdown_aisle_processor"
  end

  it 'should be able to fetch home page' do

    VCR.use_cassette('fetch_homepage', :match_requests_on => [:method, :uri, :query]) do
      doc = CountdownAisleProcessor.home_doc_fetch

      expect(doc.class).to eq(Nokogiri::HTML::Document)
      expect(doc.at_css('title').text.strip).to eq('Online Supermarket: Online Grocery Shopping & Free Recipes at countdown.co.nz')
      expect(doc.at_css('.copyright-wrapper').at_css('.visible-phone').text.strip).to eq("© Countdown #{Time.now.year}")
    end
  end
end

describe 'more than 24 products in an aisle' do
  before do
    require "#{Rails.root}/lib/modules/countdown_aisle_processor"
  end

  it 'should be able to retrieve more than 25 products' do
    cache = ActiveSupport::Cache::FileStore.new('/tmp')

    VCR.use_cassette('more_than_25', :match_requests_on => [:method, :uri, :query], :re_record_interval => nil) do
      CountdownAisleProcessor\
             .grab_browse_aisle('/Shop/Browse/personal-care/oral-care', cache)

      expect(Product.count).to eq(183)
    end
  end
end

describe 'rproxy, webscrape, countdown links' do
  before do
    require "#{Rails.root}/lib/modules/countdown_links_processor"
    require "#{Rails.root}/lib/modules/countdown_aisle_processor"
  end

  it 'should be able to process various links' do
    cache = ActiveSupport::Cache::FileStore.new('/tmp')
    VCR.use_cassette('fetch_homepage', :match_requests_on => [:method, :uri, :query]) do
      doc = CountdownAisleProcessor.home_doc_fetch
      VCR.use_cassette('aisles', :match_requests_on => [:method, :uri, :query]) do
        aisles = CountdownLinksProcessor.generate_aisle(doc, cache)
        expect(aisles.size).to eq(3120)
        expect(aisles.first).to include('/Shop/Browse/bakery/')
        expect(aisles.last).to include('/Shop/Browse/toys-party-needs/')
      end
    end
  end
end

describe 'rproxy, webscrape, countdown aisles' do
  before :each do
    require "#{Rails.root}/lib/modules/countdown_aisle_processor"
    require "#{Rails.root}/lib/modules/rake_logger"
    @cache = ActiveSupport::Cache::FileStore.new('/tmp')
    @cap = CountdownAisleProcessor.new
    @logger = RakeLogger.new
  end

  it 'should be able to process special price product' do
    doc = Cacher.cache_retrieve_url(@cache, '/Shop/Deals/bakery/bread-rolls-bread-sticks-bagels/bagels')
    html = Nokogiri::HTML(doc)
    aisle = @cap.aisle_name(html)
    items = html.css('div.product-stamp.product-stamp-grid')

    expect(aisle).to eq('deals, bakery, bread rolls, bread sticks & bagels, bagels')
    expect(items.count).to eq(1)
    expect(@cap.special_price?(items.first)).to eq(true)
    expect(@cap.process_item(items.first, aisle, @logger)).to eq(true)

    expect(NormalPrice.all.size).to eq(1)
    expect(NormalPrice.where(product_id: 1).first.price).to eq(5.99)
    expect(SpecialPrice.all.size).to eq(1)
    expect(SpecialPrice.where(product_id: 1).first.price).to eq(5.50)
  end

  it 'should be able to process basic multi buy product' do
    doc = Cacher.cache_retrieve_url(@cache, '/Shop/Deals/bakery/bread-rolls-bread-sticks-bagels/baguette')
    html = Nokogiri::HTML(doc)
    aisle = @cap.aisle_name(html)
    items = html.css('div.product-stamp.product-stamp-grid')

    expect(aisle).to eq('deals, bakery, bread rolls, bread sticks & bagels, baguette')
    expect(items.count).to eq(1)
    expect(@cap.special_price?(items.first)).to eq(false)
    expect(@cap.process_item(items.first, aisle, @logger)).to eq(true)

    expect(NormalPrice.all.size).to eq(2)
    expect(NormalPrice.where(product_id: 2).first.price).to eq(1.99)
    expect(SpecialPrice.all.size).to eq(2)
    expect(SpecialPrice.where(product_id: 2).first.price).to eq(1.50)
  end
end