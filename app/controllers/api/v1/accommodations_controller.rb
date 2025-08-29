module Api
  module V1
    class AccommodationsController < ApplicationController
      before_action :set_accommodation, only: %i[show update destroy]

      def index
        accommodations = Accommodation.all
        render json: accommodations
      end

      def show
        render json: @accommodation
      end

      def create
        accommodation = Accommodation.new(accommodation_params)
        if accommodation.save
          render json: accommodation, status: :created
        else
          render json: accommodation.errors, status: :unprocessable_entity
        end
      end

      def update
        if @accommodation.update(accommodation_params)
          render json: @accommodation
        else
          render json: @accommodation.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @accommodation.destroy
        head :no_content
      end

      private

      def set_accommodation
        @accommodation = Accommodation.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { }, status: :not_found
      end

      def accommodation_params
        params.require(:accommodation).permit(:name, :description, :price, :location)
      end
    end
  end
end
