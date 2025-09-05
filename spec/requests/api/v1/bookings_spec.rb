# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Bookings', type: :request do
  let!(:accommodation) { create(:accommodation) }
  let!(:bookings) { create_list(:booking, 3, accommodation: accommodation) }
  let(:existing_booking) { bookings.first }

  path '/api/v1/accommodations/{accommodation_id}/bookings' do
    parameter name: :accommodation_id, in: :path, type: :integer, description: 'Accommodation ID'

    get 'List all bookings for an accommodation' do
      tags 'Bookings'
      produces 'application/json'

      response '200', 'bookings found' do
        let(:accommodation_id) { accommodation.id }

        run_test! do
          body = JSON.parse(response.body)['bookings']
          expect(body.size).to eq(3)
          expect(body.first.keys).to include('id', 'accommodation_id', 'start_date', 'end_date', 'guest_name')
        end
      end
    end
  end

  path '/api/v1/bookings' do
    get 'List all bookings' do
      tags 'Bookings'
      produces 'application/json'

      response '200', 'all bookings returned' do
        run_test! do
          body = JSON.parse(response.body)['bookings']
          expect(body.size).to eq(3)
        end
      end
    end
  end

  path '/api/v1/bookings/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Booking ID'

    get 'Retrieve a booking' do
      tags 'Bookings'
      produces 'application/json'

      response '200', 'booking found' do
        let(:id) { existing_booking.id }

        run_test! do
          body = JSON.parse(response.body)['booking']
          expect(body['id']).to eq(existing_booking.id)
        end
      end

      response '404', 'booking not found' do
        let(:id) { 0 }
        run_test!
      end
    end

    patch 'Update a booking' do
      tags 'Bookings'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :booking, in: :body, schema: {
        type: :object,
        properties: {
          booking: {
            type: :object,
            properties: {
              guest_name: { type: :string },
              start_date: { type: :string, format: 'date' },
              end_date: { type: :string, format: 'date' }
            },
            required: ['guest_name']
          }
        },
        required: ['booking']
      }

      response '200', 'booking updated' do
        let(:id) { existing_booking.id }
        let(:booking) { { booking: { guest_name: 'Jane Doe' } } }

        run_test! do
          expect(existing_booking.reload.guest_name).to eq('Jane Doe')
        end
      end

      response '422', 'invalid request' do
        let(:id) { existing_booking.id }
        let(:booking) { { booking: { start_date: nil } } }
        run_test!
      end
    end

    delete 'Delete a booking' do
      tags 'Bookings'
      produces 'application/json'

      response '204', 'booking deleted' do
        let(:id) { existing_booking.id }

        run_test! do
          expect(Booking.exists?(id)).to be_falsey
        end
      end

      response '404', 'booking not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end
end
