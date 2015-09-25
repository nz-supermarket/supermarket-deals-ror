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