# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Hotels', type: :request do
  path '/api/v1/hotels' do
    get 'Retrieves paginated hotels' do
      tags 'Hotels'
      produces 'application/json'

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
