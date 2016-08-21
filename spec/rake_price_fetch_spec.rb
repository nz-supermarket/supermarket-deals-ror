require 'rails_helper'
require 'nokogiri'
require 'pry-byebug'
require 'rake'

describe 'rproxy, webscrape, countdown homepage' do
  before do
    require "#{Rails.root}/lib/modules/countdown/home_page_fetcher"
  end

  it 'should be able to fetch home page' do
    doc = Countdown::HomePageFetcher.nokogiri_open_url

    expect(doc.class).to eq(Nokogiri::HTML::Document)
    expect(doc.at_css('title').text.strip)\
      .to eq('Online Supermarket: Online Grocery Shopping & Free Recipes at countdown.co.nz')
    expect(doc.at_css('.copyright-wrapper')\
      .at_css('.visible-phone').text.strip)\
      .to eq("© Countdown 2015")
  end
end

describe 'more than 24 products in an aisle' do
  before do
    require "#{Rails.root}/lib/modules/countdown/aisle_processor"
    require "#{Rails.root}/app/models/product"
    require "#{Rails.root}/app/models/special_price"
    require "#{Rails.root}/app/models/normal_price"

    cache = ActiveSupport::Cache::FileStore.new('/tmp')
    @ap = Countdown::AisleProcessor.new(cache)
  end

  it 'should be able to retrieve more than 25 products' do
    count = @ap.grab_individual_aisle('/Shop/Browse/personal-care/oral-care')

    expect(count).to be_between(160, 250)
  end
end

describe 'rproxy, webscrape, countdown links' do
  before do
    require "#{Rails.root}/lib/modules/countdown/links_processor"
    require "#{Rails.root}/lib/modules/countdown/aisle_processor"
  end

  it 'should be able to process various links' do
    cache = ActiveSupport::Cache::FileStore.new('/tmp')
    lp = Countdown::LinksProcessor
         .new(Countdown::HomePageFetcher
                .nokogiri_open_url, cache)
    aisles = lp.generate_aisle
    expect(aisles).to include('/Shop/Browse/meat-seafood/smoked-fish/smoked-salmon')
    expect(aisles).to include('/Shop/Browse/toys-party-needs/disposable-cutlery-dinnerware/straws')
  end
end
