# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Hotels Rooms API', type: :request do
  let!(:hotel) { create(:hotel) }
  let!(:amenity1) { create(:amenity, name: 'WiFi') }
  let!(:amenity2) { create(:amenity, name: 'Air Conditioning') }

  let!(:room) do
    create(:room,
           hotel: hotel,
           name: 'Deluxe Suite',
           description: 'Spacious room with sea view',
           price: 200,
           location: 'Ocean Wing',
           capacity: 4,
           address: '123 Beach Ave',
           amenities: [amenity1, amenity2])
  end

  path '/api/v1/hotels/{hotel_id}/rooms' do
    get 'Lists rooms for a hotel' do
      tags 'Rooms'
      produces 'application/json'
      parameter name: :hotel_id, in: :path, type: :integer
      parameter name: :page, in: :query, type: :integer
      parameter name: :per_page, in: :query, type: :integer

      response '200', 'rooms listed' do
        let(:hotel_id) { hotel.id }
        let(:page) { 1 }
        let(:per_page) { 10 }

        run_test! do
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json['rooms'].size).to eq(1)
          expect(json['rooms'].first['name']).to eq(room.name)
          expect(json['rooms'].first['amenities'].map { |a| a['name'] }).to include('WiFi', 'Air Conditioning')
          expect(json['meta']).to include('current_page', 'total_pages', 'total_count')
        end
      end

      response '404', 'hotel not found' do
        let(:hotel_id) { 0 }
        let(:page) { 1 }
        let(:per_page) { 10 }

        run_test!
      end
    end

    post 'Creates a new room for a hotel' do
      tags 'Rooms'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :hotel_id, in: :path, type: :integer
      parameter name: :room_params, in: :body, schema: {
        type: :object,
        properties: {
          room: {
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
            required: %w[name description price location capacity address]
          }
        }
      }

      let(:hotel_id) { hotel.id }
      let(:valid_room) do
        {
          room: {
            name: 'Presidential Suite',
            description: 'Luxury suite with private pool',
            price: 500,
            location: 'Penthouse',
            capacity: 6,
            address: '123 Beach Ave',
            amenities_attributes: [{ name: 'Jacuzzi' }, { name: 'WiFi' }]
          }
        }
      end

      let(:invalid_room) { { room: { name: '', description: 'Broken room' } } }

      response '201', 'room created' do
        let(:room_params) { valid_room }
        run_test! do
          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json['room']['name']).to eq('Presidential Suite')
          expect(json['room']['amenities'].map { |a| a['name'] }).to include('Jacuzzi', 'WiFi')
        end
      end

      response '422', 'invalid room params' do
        let(:room_params) { invalid_room }
        run_test! do
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json).to have_key('errors')
        end
      end
    end
  end

  path '/api/v1/hotels/{hotel_id}/rooms/{id}' do
    get 'Retrieves a single room' do
      tags 'Rooms'
      produces 'application/json'
      parameter name: :hotel_id, in: :path, type: :integer
      parameter name: :id, in: :path, type: :integer

      response '200', 'room found' do
        let(:hotel_id) { hotel.id }
        let(:id) { room.id }

        run_test! do
          get "/api/v1/hotels/#{hotel_id}/rooms/#{id}"
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json['room']['name']).to eq(room.name)
          expect(json['room']['amenities'].map { |a| a['name'] }).to include('WiFi', 'Air Conditioning')
        end
      end

      response '404', 'room not found' do
        let(:hotel_id) { hotel.id }
        let(:id) { 0 }

        run_test! do
          get "/api/v1/hotels/#{hotel_id}/rooms/#{id}"
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    patch 'Updates a room' do
      tags 'Rooms'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :hotel_id, in: :path, type: :integer
      parameter name: :id, in: :path, type: :integer
      parameter name: :room_params, in: :body, schema: {
        type: :object,
        properties: {
          room: {
            type: :object,
            properties: {
              name: { type: :string },
              price: { type: :number },
              amenities_attributes: {
                type: :array,
                items: { type: :object, properties: { name: { type: :string } } }
              }
            }
          }
        }
      }

      let(:hotel_id) { hotel.id }
      let(:id) { room.id }
      let(:valid_update) { { room: { price: 550, amenities_attributes: [{ name: 'Mini Bar' }] } } }
      let(:invalid_update) { { room: { name: '' } } }

      response '200', 'room updated' do
        let(:room_params) { valid_update }

        run_test! do
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json['room']['price']).to eq(room.reload.price.to_f.to_s)
          expect(json['room']['amenities'].map { |a| a['name'] }).to include('Mini Bar')
        end
      end

      response '422', 'invalid update params' do
        let(:room_params) { invalid_update }

        run_test! do
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json).to have_key('errors')
        end
      end
    end

    delete 'Deletes a room' do
      tags 'Rooms'
      produces 'application/json'
      parameter name: :hotel_id, in: :path, type: :integer
      parameter name: :id, in: :path, type: :integer

      let(:hotel_id) { hotel.id }
      let(:id) { room.id }

      response '204', 'room deleted' do
        run_test! do
          expect(response).to have_http_status(:no_content)
          expect(hotel.rooms.reload.count).to eq(0)
        end
      end

      response '404', 'room not found' do
        let(:id) { 0 }

        run_test! do
          delete "/api/v1/hotels/#{hotel_id}/rooms/#{id}"
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
