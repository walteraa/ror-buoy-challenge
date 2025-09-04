# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ApartmentsController, type: :request do
  let!(:apartments) { create_list(:apartment, 3) }
  let(:apartment)   { apartments.first }

  describe 'GET /api/v1/apartments' do
    it 'returns paginated apartments with status 200' do
      get '/api/v1/apartments'

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body).to have_key('apartments')
      expect(body['apartments'].size).to eq(3)
      expect(body).to have_key('meta')
      expect(body['meta']).to include('current_page', 'total_pages', 'total_count')
    end
  end

  describe 'GET /api/v1/apartments/:id' do
    context 'when apartment exists' do
      it 'returns the apartment with status 200' do
        get "/api/v1/apartments/#{apartment.id}"

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body).to have_key('apartment')
        expect(body['apartment']['id']).to eq(apartment.id)
      end
    end

    context 'when apartment does not exist' do
      it 'returns 404 not found' do
        get '/api/v1/apartments/0'

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/apartments' do
    let(:valid_params) do
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

    let(:invalid_params) do
      {
        apartment: {
          name: '',
          price: nil
        }
      }
    end

    context 'with valid params' do
      it 'creates an apartment and returns status 201' do
        expect do
          post '/api/v1/apartments', params: valid_params
        end.to change(Apartment, :count).by(1)

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body).to have_key('apartment')
        expect(body['apartment']['name']).to eq('New Apartment')
      end
    end

    context 'with invalid params' do
      it 'returns 422 unprocessable entity' do
        post '/api/v1/apartments', params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body).to have_key('errors')
      end
    end
  end

  describe 'PATCH /api/v1/apartments/:id' do
    let(:valid_update)   { { apartment: { name: 'Updated Name' } } }
    let(:invalid_update) { { apartment: { name: '' } } }

    context 'with valid params' do
      it 'updates the apartment and returns status 200' do
        patch "/api/v1/apartments/#{apartment.id}", params: valid_update

        expect(response).to have_http_status(:ok)
        expect(apartment.reload.name).to eq('Updated Name')
      end
    end

    context 'with invalid params' do
      it 'returns 422 unprocessable entity' do
        patch "/api/v1/apartments/#{apartment.id}", params: invalid_update

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body).to have_key('errors')
      end
    end
  end

  describe 'DELETE /api/v1/apartments/:id' do
    it 'destroys the apartment and returns 204' do
      expect do
        delete "/api/v1/apartments/#{apartment.id}"
      end.to change(Apartment, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
