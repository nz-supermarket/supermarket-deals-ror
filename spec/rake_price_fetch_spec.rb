require 'rails_helper'
require 'nokogiri'
require 'pry-byebug'
require 'rake'

describe 'rproxy, webscrape, countdown homepage' do
  before do
    require "#{Rails.root}/lib/modules/countdown_aisle_processor"
  end

  it 'should be able to fetch home page' do
    doc = CountdownAisleProcessor.home_doc_fetch

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
    require "#{Rails.root}/lib/modules/countdown_aisle_processor"
    require "#{Rails.root}/app/models/product"
    require "#{Rails.root}/app/models/special_price"
    require "#{Rails.root}/app/models/normal_price"
  end

  it 'should be able to retrieve more than 25 products' do
    cache = ActiveSupport::Cache::FileStore.new('/tmp')

    CountdownAisleProcessor\
      .grab_browse_aisle('/Shop/Browse/personal-care/oral-care', cache)

    expect(Product.count).to be_between(160, 210)
  end
end

describe 'rproxy, webscrape, countdown links' do
  before do
    require "#{Rails.root}/lib/modules/countdown_links_processor"
    require "#{Rails.root}/lib/modules/countdown_aisle_processor"
  end

  it 'should be able to process various links' do
    cache = ActiveSupport::Cache::FileStore.new('/tmp')
    doc = CountdownAisleProcessor.home_doc_fetch
    aisles = CountdownLinksProcessor.generate_aisle(doc, cache)
    expect(aisles.first).to include('/Shop/Browse/bakery/')
    expect(aisles.last).to include('/Shop/Browse/toys-party-needs/')
  end
end

describe 'rproxy, webscrape, countdown aisles' do
  before :each do
    require "#{Rails.root}/lib/modules/countdown_aisle_processor"
    require "#{Rails.root}/lib/modules/countdown_item_processor"
    require "#{Rails.root}/lib/modules/rake_logger"
    @cache = ActiveSupport::Cache::FileStore.new('/tmp')
  end

  it 'should be able to process special price product' do
    doc = Cacher.cache_retrieve_url(@cache, '/Shop/Browse/bakery/bread-rolls-bread-sticks-bagels/sliders')
    html = Nokogiri::HTML(doc)
    aisle = CountdownAisleProcessor.aisle_name(html)
    items = html.css('div.product-stamp.product-stamp-grid')

    expect(aisle).to eq('bakery, bread rolls, bread sticks & bagels, sliders')
    expect(items.count).to be_between(1, 5)
    expect(
      CountdownItemProcessor.special_price?(items.first) ||
      CountdownItemProcessor.multi_buy?(items.first)
    ).to eq(true)

    CountdownItemProcessor.process_item(nil, items.first, aisle)

    expect(NormalPrice.all.size).to be_between(1, 5)
    expect(NormalPrice.where(product_id: 1).first.price).to eq(4.19)
    expect(SpecialPrice.all.size).to be_between(1, 5)
    expect(SpecialPrice.where(product_id: 1).first.price).to eq(3.00)
  end

  it 'should be able to process basic multi buy product' do
    doc = Cacher.cache_retrieve_url(@cache, '/Shop/Browse/bakery/bread-rolls-bread-sticks-bagels/sliders')
    html = Nokogiri::HTML(doc)
    aisle = CountdownAisleProcessor.aisle_name(html)
    items = html.css('div.product-stamp.product-stamp-grid')

    expect(aisle)\
      .to eq('bakery, bread rolls, bread sticks & bagels, sliders')
    expect(items.count).to be_between(1, 5)
    expect(
      CountdownItemProcessor.special_price?(items.first) ||
      CountdownItemProcessor.multi_buy?(items.first)
    ).to eq(true)

    CountdownItemProcessor.process_item(nil, items.first, aisle)

    expect(NormalPrice.all.size).to be_between(1, 5)
    expect(NormalPrice.where(product_id: 1).first.price).to eq(4.19)
    expect(SpecialPrice.all.size).to be_between(1, 5)
    expect(SpecialPrice.where(product_id: 1).first.price).to eq(3.00)
  end
end