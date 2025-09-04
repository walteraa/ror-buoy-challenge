# frozen_string_literal: true

module Api
  module V1
    class ApartmentsController < ApplicationController
      before_action :set_apartment, only: %i[show update destroy]

      def index
        @apartments = Apartment.page(params[:page]).per(params[:per_page] || 10)
        render json: @apartments, each_serializer: ::V1::ApartmentSerializer, meta: pagination_meta(@apartments)
      end

      def show
        render json: @apartment, serializer: ::V1::ApartmentSerializer
      end

      def create
        @apartment = Apartment.new(apartment_params)
        if @apartment.save
          render json: @apartment, serializer: ::V1::ApartmentSerializer, status: :created
        else
          render json: { errors: @apartment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @apartment.update(apartment_params)
          render json: @apartment, serializer: ::V1::ApartmentSerializer
        else
          render json: { errors: @apartment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @apartment.destroy
        head :no_content
      end

      private

      def set_apartment
        @apartment = Apartment.find(params[:id])
      end

      def apartment_params
        params.require(:apartment).permit(
          :name, :description, :price, :location, :capacity, :address,
          amenities_attributes: %i[id name _destroy]
        )
      end

      def pagination_meta(object)
        {
          current_page: object.current_page,
          total_pages: object.total_pages,
          total_count: object.total_count
        }
      end
    end
  end
end
