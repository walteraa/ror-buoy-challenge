# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Apartments', type: :request do
  let!(:apartments) { create_list(:apartment, 3) }
  let(:existing_apartment) { apartments.first }

  path '/api/v1/apartments' do
    get 'List apartments' do
      tags 'Apartments'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, description: 'Page number', required: false
      parameter name: :per_page, in: :query, type: :integer, description: 'Results per page', required: false

      parameter name: :start_date, in: :query, type: :string, format: :date,
                description: 'Filter by availability start date', required: false
      parameter name: :end_date, in: :query, type: :string, format: :date,
                description: 'Filter by availability end date', required: false

      parameter name: :amenities, in: :query, type: :array, collectionFormat: :multi,
                items: { type: :string }, description: 'Filter by amenities (e.g., amenities[]=WiFi&amenities[]=Pool)', required: false

      response '200', 'apartments found' do
        run_test! do
          body = JSON.parse(response.body)
          expect(body['apartments'].size).to eq(3)
          expect(body).to have_key('meta')
        end
      end

      response '200', 'apartments filtered by availability' do
        let!(:available_apartment) do
          apartment = create(:apartment)
          create(:apartment)
          apartment
        end

        let!(:booked_apartment) do
          apartment = create(:apartment)
          create(:booking, accommodation: apartment, start_date: '2025-09-10', end_date: '2025-09-20')
          apartment
        end

        before do
          get '/api/v1/apartments', params: { start_date: '2025-09-15', end_date: '2025-09-16' }
        end

        it 'returns only apartments with availability' do
          body = JSON.parse(response.body)
          apartment_ids = body['apartments'].map { |a| a['id'] }

          expect(apartment_ids).to include(available_apartment.id)
          expect(apartment_ids).not_to include(booked_apartment.id)
        end
      end

      response '200', 'apartments filtered by amenities' do
        let!(:wifi) { create(:amenity, name: 'WiFi') }
        let!(:pool) { create(:amenity, name: 'Pool') }

        let!(:apartment_with_wifi_and_pool) do
          apartment = create(:apartment)
          apartment.amenities << wifi
          apartment.amenities << pool
          apartment
        end

        let!(:apartment_with_only_wifi) do
          apartment = create(:apartment)
          apartment.amenities << wifi
          apartment
        end

        before do
          get '/api/v1/apartments', params: { amenities: %w[WiFi Pool] }
        end

        it 'returns only apartments that have all requested amenities' do
          body = JSON.parse(response.body)
          apartment_ids = body['apartments'].map { |a| a['id'] }

          expect(apartment_ids).to include(apartment_with_wifi_and_pool.id)
          expect(apartment_ids).not_to include(apartment_with_only_wifi.id)
        end
      end

      response '200', 'apartments filtered by availability AND amenities' do
        let!(:wifi) { create(:amenity, name: 'WiFi') }

        let!(:available_apartment_with_wifi) do
          apartment = create(:apartment)
          apartment.amenities << wifi
          apartment
        end

        let!(:booked_apartment_with_wifi) do
          apartment = create(:apartment)
          apartment.amenities << wifi
          create(:booking, accommodation: apartment, start_date: '2025-09-10', end_date: '2025-09-20')
          apartment
        end

        before do
          get '/api/v1/apartments', params: { start_date: '2025-09-15', end_date: '2025-09-16', amenities: ['WiFi'] }
        end

        it 'returns only apartments that match both filters' do
          body = JSON.parse(response.body)
          apartment_ids = body['apartments'].map { |a| a['id'] }

          expect(apartment_ids).to include(available_apartment_with_wifi.id)
          expect(apartment_ids).not_to include(booked_apartment_with_wifi.id)
        end
      end
      response '200', 'apartments filtered by availability' do
        let!(:available_apartment) { create(:apartment) }
        let!(:booked_apartment) do
          apartment = create(:apartment)
          create(:booking, accommodation: apartment,
                           start_date: '2025-09-10', end_date: '2025-09-20')
          apartment
        end

        before do
          get '/api/v1/apartments', params: { start_date: '2025-09-15', end_date: '2025-09-16' }
        end

        it 'returns only apartments with availability' do
          body = JSON.parse(response.body)
          apartment_ids = body['apartments'].map { |a| a['id'] }

          expect(apartment_ids).to include(available_apartment.id)
          expect(apartment_ids).not_to include(booked_apartment.id)
        end
      end

      response '200', 'apartments filtered by amenities' do
        let!(:wifi) { create(:amenity, name: 'WiFi') }
        let!(:pool) { create(:amenity, name: 'Pool') }

        let!(:apartment_with_wifi_and_pool) do
          apartment = create(:apartment)
          apartment.amenities << wifi
          apartment.amenities << pool
          apartment
        end

        let!(:apartment_with_only_wifi) do
          apartment = create(:apartment)
          apartment.amenities << wifi
          apartment
        end

        before do
          get '/api/v1/apartments', params: { amenities: %w[WiFi Pool] }
        end

        it 'returns only apartments that have all requested amenities' do
          body = JSON.parse(response.body)
          apartment_ids = body['apartments'].map { |a| a['id'] }

          expect(apartment_ids).to include(apartment_with_wifi_and_pool.id)
          expect(apartment_ids).not_to include(apartment_with_only_wifi.id)
        end
      end

      response '200', 'apartments filtered by availability AND amenities' do
        let!(:wifi) { create(:amenity, name: 'WiFi') }

        let!(:available_apartment_with_wifi) do
          apartment = create(:apartment)
          apartment.amenities << wifi
          apartment
        end

        let!(:booked_apartment_with_wifi) do
          apartment = create(:apartment)
          apartment.amenities << wifi
          create(:booking, accommodation: apartment,
                           start_date: '2025-09-10', end_date: '2025-09-20')
          apartment
        end

        before do
          get '/api/v1/apartments', params: {
            start_date: '2025-09-15',
            end_date: '2025-09-16',
            amenities: ['WiFi']
          }
        end

        it 'returns only apartments that match both filters' do
          body = JSON.parse(response.body)
          apartment_ids = body['apartments'].map { |a| a['id'] }

          expect(apartment_ids).to include(available_apartment_with_wifi.id)
          expect(apartment_ids).not_to include(booked_apartment_with_wifi.id)
        end
      end
    end

    post 'Create an apartment' do
      tags 'Apartments'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :apartment, in: :body, schema: {
        type: :object,
        properties: {
          apartment: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              price: { type: :number },
              location: { type: :string },
              capacity: { type: :integer },
              address: { type: :string },
              amenities_attributes: {
                type: :array,
                items: { type: :object, properties: { name: { type: :string } } }
              }
            },
            required: %w[name price location capacity address]
          }
        },
        required: ['apartment']
      }

      response '201', 'apartment created' do
        let(:apartment) do
          {
            apartment: {
              name: 'New Apartment',
              description: 'Cozy place',
              price: 1200,
              location: 'Downtown',
              capacity: 3,
              address: '123 Main St',
              amenities_attributes: [{ name: 'Balcony' }]
            }
          }
        end

        run_test! do
          body = JSON.parse(response.body)
          expect(body['apartment']['name']).to eq('New Apartment')
        end
      end

      response '422', 'invalid request' do
        let(:apartment) { { apartment: { name: '', price: nil } } }
        run_test!
      end
    end
  end

  path '/api/v1/apartments/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Apartment ID'

    get 'Retrieve an apartment' do
      tags 'Apartments'
      produces 'application/json'

      response '200', 'apartment found' do
        let(:id) { existing_apartment.id }
        run_test! do
          body = JSON.parse(response.body)
          expect(body['apartment']['id']).to eq(existing_apartment.id)
        end
      end

      response '404', 'apartment not found' do
        let(:id) { 0 }
        run_test!
      end
    end

    patch 'Update an apartment' do
      tags 'Apartments'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :apartment, in: :body, schema: {
        type: :object,
        properties: {
          apartment: {
            type: :object,
            properties: {
              name: { type: :string }
            },
            required: ['name']
          }
        },
        required: ['apartment']
      }

      response '200', 'apartment updated' do
        let(:id) { existing_apartment.id }
        let(:apartment) { { apartment: { name: 'Updated Name' } } }

        run_test! do
          expect(existing_apartment.reload.name).to eq('Updated Name')
        end
      end

      response '422', 'invalid request' do
        let(:id) { existing_apartment.id }
        let(:apartment) { { apartment: { name: '' } } }
        run_test!
      end
    end

    delete 'Delete an apartment' do
      tags 'Apartments'
      produces 'application/json'

      response '204', 'apartment deleted' do
        let(:id) { existing_apartment.id }

        run_test! do
          expect(Apartment.exists?(id)).to be_falsey
        end
      end

      response '404', 'apartment not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end
end
