# frozen_string_literal: true

module Api
  module V1
    module Hotels
      class RoomsController < ApplicationController
        before_action :set_hotel
        before_action :set_room, only: %i[show update destroy]

        def index
          @rooms = @hotel.rooms.page(params[:page]).per(params[:per_page] || 10)
          render json: @rooms, each_serializer: ::V1::RoomSerializer, meta: pagination_meta(@rooms)
        end

        def show
          render json: @room, serializer: ::V1::RoomSerializer
        end

        def create
          @room = @hotel.rooms.build(room_params)
          if @room.save
            render json: @room, serializer: ::V1::RoomSerializer, status: :created
          else
            render json: { errors: @room.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          if @room.update(room_params)
            render json: @room, serializer: ::V1::RoomSerializer
          else
            render json: { errors: @room.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          @room.destroy
          head :no_content
        end

        private

        def set_hotel
          @hotel = Hotel.find(params[:hotel_id])
        end

        def set_room
          @room = @hotel.rooms.find(params[:id])
        end

        def room_params
          params.require(:room).permit(
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
end
