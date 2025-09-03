# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API V1 - Bookings', type: :request do
  path '/api/v1/accommodations/{accommodation_id}/bookings' do
    get 'List bookings for a specific accommodation' do
      tags 'Bookings'
      produces 'application/json'
      parameter name: :accommodation_id, in: :path, type: :string

      response '200', 'bookings listed' do
        let(:accommodation_id) { Accommodation.create!(name: 'Flat 3', price: 150.00, location: 'Gate').id }
        run_test!
      end
    end

    post 'Create booking for an accommodation' do
      tags 'Bookings'
      consumes 'application/json'
      parameter name: :accommodation_id, in: :path, type: :string
      parameter name: :booking, in: :body, schema: {
        type: :object,
        properties: {
          guest_name: { type: :string },
          start_date: { type: :string, format: :date },
          end_date: { type: :string, format: :date }
        },
        required: %w[guest_name start_date end_date]
      }

      response '201', 'booking created' do
        let(:accommodation_id) { Accommodation.create!(name: 'Booking Acc', price: 500.00, location: 'Miami').id }
        let(:booking) do
          {
            guest_name: 'Ana',
            start_date: Date.today.to_s,
            end_date: (Date.today + 2).to_s,
            accommodation_id: accommodation_id
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/bookings' do
    get 'List all bookings' do
      tags 'Bookings'
      produces 'application/json'

      response '200', 'bookings listed' do
        run_test!
      end
    end
  end

  path '/api/v1/bookings/{id}' do
    get 'Get a booking by ID' do
      tags 'Bookings'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'booking found' do
        let(:accommodation) { Accommodation.create!(name: 'Unit Test Acc', price: 100.00, location: 'Street A') }
        let(:id) do
          Booking.create!(accommodation: accommodation, guest_name: 'Carl', start_date: Date.today,
                          end_date: Date.today + 1).id
        end
        run_test!
      end

      response '404', 'booking not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    patch 'Update a booking' do
      tags 'Bookings'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :booking, in: :body, schema: {
        type: :object,
        properties: {
          guest_name: { type: :string },
          start_date: { type: :string, format: :date },
          end_date: { type: :string, format: :date }
        }
      }

      response '200', 'booking updated' do
        let(:accommodation) { Accommodation.create!(name: 'Test', price: 300.00, location: 'downtown') }
        let(:id) do
          Booking.create!(accommodation: accommodation, guest_name: 'John', start_date: Date.today,
                          end_date: Date.today + 1).id
        end
        let(:booking) { { guest_name: 'John Smith' } }
        run_test!
      end
    end

    delete 'Delete a booking' do
      tags 'Bookings'
      parameter name: :id, in: :path, type: :string

      response '204', 'booking deleted' do
        let(:accommodation) { Accommodation.create!(name: 'Test', price: 300, location: 'downtown') }
        let(:id) do
          Booking.create!(accommodation: accommodation, guest_name: 'Mary', start_date: Date.today,
                          end_date: Date.today + 1).id
        end
        run_test!
      end
    end
  end
end
