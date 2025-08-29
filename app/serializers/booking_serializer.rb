class BookingSerializer < ActiveModel::Serializer
  attributes :id, :accommodation_id, :accommodation_name, :start_date, :end_date, :guest_name

  def accommodation_name
    object.accommodation&.name
  end
end
