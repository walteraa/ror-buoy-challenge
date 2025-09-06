# frozen_string_literal: true

module Api
  module V1
    class HotelsController < ApplicationController
      before_action :set_hotel, only: %i[show update destroy]

      def index
        permitted_params = params.permit(amenities: [])
        hotels = Hotel.all

        if params[:start_date].present? && params[:end_date].present?
          hotels = hotels.available(params[:start_date], params[:end_date])
        end

        if permitted_params[:amenities].present? && permitted_params[:amenities].is_a?(Array) && params[:amenities].any?
          hotels = hotels.with_amenities(permitted_params[:amenities])
        end

        @hotels = hotels.page(params[:page]).per(params[:per_page] || 10)
        render json: @hotels, each_serializer: ::V1::HotelSerializer, meta: pagination_meta(@hotels)
      end

      def show
        render json: @hotel, serializer: ::V1::HotelSerializer
      end

      def create
        @hotel = Hotel.new(hotel_params)
        if @hotel.save
          render json: @hotel, serializer: ::V1::HotelSerializer, status: :created
        else
          render json: { errors: @hotel.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @hotel.update(hotel_params)
          render json: @hotel, serializer: ::V1::HotelSerializer
        else
          render json: { errors: @hotel.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @hotel.destroy
        head :no_content
      end

      private

      def set_hotel
        @hotel = Hotel.find(params[:id])
      end

      def hotel_params
        params.require(:hotel).permit(
          :name, :address,
          rooms_attributes: [
            :id, :name, :description, :price, :location, :capacity, :address, :_destroy,
            { amenities_attributes: %i[id name _destroy] }
          ],
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
