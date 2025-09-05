# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Apartments', type: :request do
  let!(:apartments) { create_list(:apartment, 3) }
  let(:existing_apartment) { apartments.first }

  path '/api/v1/apartments' do
    get 'List apartments' do
      tags 'Apartments'
      produces 'application/json'

      response '200', 'apartments found' do
        run_test! do
          body = JSON.parse(response.body)
          expect(body['apartments'].size).to eq(3)
          expect(body).to have_key('meta')
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
