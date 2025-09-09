# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Accommodations API', type: :request do
  let!(:accommodations) { create_list(:accommodation, 3) }
  let(:accommodation)   { accommodations.first }

  path '/api/v1/accommodations' do
    get 'Lists accommodations' do
      tags 'Accommodations'
      produces 'application/json'

      response '200', 'accommodations listed' do
        run_test! do
          expect(response).to have_http_status(:ok)
          body = JSON.parse(response.body)
          expect(body).to have_key('accommodations')
          expect(body['accommodations'].size).to eq(3)
          expect(body).to have_key('meta')
          expect(body['meta']).to include('current_page', 'total_pages', 'total_count')
        end
      end
    end
  end

  path '/api/v1/accommodations/{id}' do
    get 'Retrieves an accommodation' do
      tags 'Accommodations'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      response '200', 'accommodation found' do
        let(:id) { accommodation.id }
        run_test! do
          expect(response).to have_http_status(:ok)
          body = JSON.parse(response.body)
          expect(body.dig('accommodation', 'name')).to eq(accommodation.name)
        end
      end

      response '404', 'accommodation not found' do
        let(:id) { 0 }
        run_test! do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  path '/api/v1/accommodations/{id}/book' do
    post 'Books an accommodation' do
      tags 'Accommodations'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer
      parameter name: :booking, in: :body, schema: {
        type: :object,
        properties: {
          start_date: { type: :string, format: :date },
          end_date: { type: :string, format: :date },
          guest_name: { type: :string }
        },
        required: %w[start_date end_date guest_name]
      }

      let(:booking) do
        {
          start_date: '2025-09-10',
          end_date: '2025-09-12',
          guest_name: 'John Doe'
        }
      end

      response '202', 'booking request created' do
        let(:id) { accommodation.id }
        run_test! do
          expect(response).to have_http_status(:accepted)
          body = JSON.parse(response.body)
          expect(body).to include('message', 'booking_request_id')
        end
      end

      response '404', 'accommodation not found' do
        let(:id) { 0 }
        run_test! do
          expect(response).to have_http_status(:not_found)
        end
      end

      response '422', 'booking creation fails' do
        let(:id) { accommodation.id }
        before do
          allow(Workflow::BookingRequest).to receive(:create!).and_raise(StandardError, 'Unexpected failure')
        end
        run_test! do
          expect(response).to have_http_status(:unprocessable_entity)
          body = JSON.parse(response.body)
          expect(body).to include('error' => 'Unexpected failure')
        end
      end
    end
  end

  path '/api/v1/accommodations/{id}/availability' do
    get 'Gets next available date for an accommodation' do
      tags 'Accommodations'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer
      parameter name: :from_date, in: :query, type: :string, format: :date, description: 'Start searching from this date'

      response '200', 'next available date returned' do
        let(:id) { accommodation.id }
        let(:from_date) { '2025-09-09' }

        before do
          create(:booking, accommodation: accommodation, start_date: '2025-09-10', end_date: '2025-09-12')
        end

        run_test! do
          expect(response).to have_http_status(:ok)
          body = JSON.parse(response.body)
          expect(body['accommodation_id']).to eq(accommodation.id)
          expect(body).to have_key('next_available')
        end
      end

      response '400', 'invalid or missing from_date' do
        let(:id) { accommodation.id }
        let(:from_date) { 'invalid-date' }

        run_test! do
          expect(response).to have_http_status(:bad_request)
          body = JSON.parse(response.body)
          expect(body).to include('error' => 'Invalid or missing from_date')
        end
      end

      response '404', 'accommodation not found' do
        let(:id) { 0 }
        let(:from_date) { '2025-09-09' }

        run_test! do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
