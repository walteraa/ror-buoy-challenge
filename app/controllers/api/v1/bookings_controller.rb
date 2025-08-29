class Api::V1::BookingsController < ApplicationController
  before_action :set_booking, only: %i[show update destroy]

  def index
    bookings = Booking.where(accommodation_id: params[:accommodation_id])
    render json: bookings
  end

  def list
    bookings = Booking.all
    render json: bookings
  end

  def create
    booking = Booking.new(booking_params)
    if booking.save
      render json: booking, status: :created
    else
      render json: booking.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: @booking
  end

  def update
    if @booking.update(booking_params)
      render json: @booking
    else
      render json: @booking.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @booking.destroy
    head :no_content
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:accommodation_id, :start_date, :end_date, :guest_name)
  end
end
