# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API V1 Workflow BookingRequests', type: :request do
  path '/api/v1/workflow/booking_requests' do
    get 'List booking requests' do
      tags 'Workflow BookingRequests'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, description: 'Items per page'

      response '200', 'booking requests listed' do
        let!(:booking_requests) { create_list(:workflow_booking_request, 3) }
        let(:page) { 1 }
        let(:per_page) { 10 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['booking_requests'].size).to eq(3)
          expect(data['meta']).to include('current_page', 'total_pages', 'total_count')
        end
      end
    end
  end

  path '/api/v1/workflow/booking_requests/{id}' do
    get 'Retrieve a single booking request' do
      tags 'Workflow BookingRequests'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string, description: 'BookingRequest ID'

      response '200', 'booking request found' do
        let(:booking_request) { create(:workflow_booking_request) }
        let(:id) { booking_request.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['booking_request']['id'].to_i).to eq(booking_request.id)
          expect(data['booking_request']).to include(
            'status' => booking_request.status,
            'accommodation_id' => booking_request.accommodation_id
          )
        end
      end

      response '404', 'booking request not found' do
        let(:id) { 'non_existent_id' }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Booking request not found')
        end
      end
    end
  end
end
