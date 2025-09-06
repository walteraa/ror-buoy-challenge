# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Hotels', type: :request do
  path '/api/v1/hotels' do
    get 'Retrieves paginated hotels' do
      tags 'Hotels'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, description: 'Page number', required: false
      parameter name: :per_page, in: :query, type: :integer, description: 'Results per page', required: false

      parameter name: :start_date, in: :query, type: :string, format: :date,
                description: 'Filter by availability start date', required: false
      parameter name: :end_date, in: :query, type: :string, format: :date,
                description: 'Filter by availability end date', required: false

      parameter name: :amenities, in: :query, type: :array, collectionFormat: :multi,
                items: { type: :string }, description: 'Filter by amenities (e.g., amenities[]=WiFi&amenities[]=Pool)', required: false

      response '200', 'hotels found' do
        let!(:hotels) { create_list(:hotel, 3) }
        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body).to have_key('hotels')
          expect(body['hotels'].size).to eq(3)
          expect(body).to have_key('meta')
          expect(body['meta']).to include('current_page', 'total_pages', 'total_count')
        end
      end

      response '200', 'hotels filtered by availability' do
        let!(:hotel_with_free_room) do
          hotel = create(:hotel)
          create(:room, hotel: hotel)
          hotel
        end

        let!(:hotel_fully_booked) do
          hotel = create(:hotel)
          room = create(:room, hotel: hotel)
          create(:booking, accommodation: room, start_date: '2025-09-10', end_date: '2025-09-20')
          hotel
        end

        let(:start_date) { '2025-09-15' }
        let(:end_date) { '2025-09-16' }

        before do
          get '/api/v1/hotels', params: { start_date: start_date, end_date: end_date }
        end

        it 'returns only hotels with availability' do
          body = JSON.parse(response.body)
          hotel_ids = body['hotels'].map { |h| h['id'] }

          expect(hotel_ids).to include(hotel_with_free_room.id)
          expect(hotel_ids).not_to include(hotel_fully_booked.id)
        end
      end

      response '200', 'hotels filtered by amenities' do
        let!(:wifi) { create(:amenity, name: 'WiFi') }
        let!(:pool) { create(:amenity, name: 'Pool') }

        let!(:hotel_with_wifi_and_pool) do
          hotel = create(:hotel)
          hotel.amenities << wifi
          hotel.amenities << pool
          hotel
        end

        let!(:hotel_without_amenity) do
          create(:hotel)
        end

        before do
          get '/api/v1/hotels', params: { amenities: %w[WiFi Pool] }
        end

        it 'returns only hotels that have all requested amenities' do
          body = JSON.parse(response.body)
          hotel_ids = body['hotels'].map { |h| h['id'] }

          expect(hotel_ids).to include(hotel_with_wifi_and_pool.id)
          expect(hotel_ids).not_to include(hotel_without_amenity.id)
        end
      end

      response '200', 'hotels filtered by availability AND amenities' do
        let!(:wifi) { create(:amenity, name: 'WiFi') }

        let!(:available_hotel_with_wifi) do
          hotel = create(:hotel)
          hotel.amenities << wifi
          create(:room, hotel: hotel) # no bookings
          hotel
        end

        let!(:booked_hotel_with_wifi) do
          hotel = create(:hotel)
          hotel.amenities << wifi
          room = create(:room, hotel: hotel)
          create(:booking, accommodation: room, start_date: '2025-09-10', end_date: '2025-09-20')
          hotel
        end

        before do
          get '/api/v1/hotels', params: { start_date: '2025-09-15', end_date: '2025-09-16', amenities: ['WiFi'] }
        end

        it 'returns only hotels that match both filters' do
          body = JSON.parse(response.body)
          hotel_ids = body['hotels'].map { |h| h['id'] }

          expect(hotel_ids).to include(available_hotel_with_wifi.id)
          expect(hotel_ids).not_to include(booked_hotel_with_wifi.id)
        end
      end
    end

    post 'Creates a hotel' do
      tags 'Hotels'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :hotel, in: :body, schema: {
        type: :object,
        properties: {
          hotel: {
            type: :object,
            properties: {
              name: { type: :string },
              address: { type: :string },
              amenities_attributes: {
                type: :array,
                items: { type: :object, properties: { name: { type: :string } } }
              }
            },
            required: %w[name address]
          }
        }
      }

      response '201', 'hotel created' do
        let(:hotel) do
          { hotel: { name: 'New Hotel', address: '123 Street', amenities_attributes: [{ name: 'Pool' }] } }
        end
        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body.dig('hotel', 'name')).to eq('New Hotel')
        end
      end

      response '422', 'unprocessable entity' do
        let(:hotel) { { hotel: { name: '', address: '' } } }
        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body).to have_key('errors')
        end
      end
    end
  end

  path '/api/v1/hotels/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Retrieves a hotel' do
      tags 'Hotels'
      produces 'application/json'

      response '200', 'hotel found' do
        let!(:hotel_record) { create(:hotel) }
        let(:id) { hotel_record.id }
        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body.dig('hotel', 'name')).to eq(hotel_record.name)
        end
      end

      response '404', 'hotel not found' do
        let(:id) { 0 }
        run_test!
      end
    end

    patch 'Updates a hotel' do
      tags 'Hotels'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :hotel, in: :body, schema: {
        type: :object,
        properties: {
          hotel: {
            type: :object,
            properties: {
              name: { type: :string },
              address: { type: :string }
            }
          }
        }
      }

      response '200', 'hotel updated' do
        let!(:hotel_record) { create(:hotel) }
        let(:id) { hotel_record.id }
        let(:hotel) { { hotel: { name: 'Updated Name' } } }
        run_test! do
          expect(hotel_record.reload.name).to eq('Updated Name')
        end
      end

      response '422', 'unprocessable entity' do
        let!(:hotel_record) { create(:hotel) }
        let(:id) { hotel_record.id }
        let(:hotel) { { hotel: { name: '' } } }
        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body).to have_key('errors')
        end
      end
    end

    delete 'Deletes a hotel' do
      tags 'Hotels'
      produces 'application/json'

      response '204', 'hotel deleted' do
        let!(:hotel_record) { create(:hotel) }
        let(:id) { hotel_record.id }
        run_test! do
          expect { Hotel.find(hotel_record.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
