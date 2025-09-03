# frozen_string_literal: true

puts 'Seeding data...'

3.times do |i|
  Accommodation.create!(
    name: "Accommodation #{i + 1}",
    description: "Sample accommodation #{i + 1}",
    price: 150.00 + i * 20,
    location: "Region #{i + 1}"
  )
end

accommodation = Accommodation.first

Booking.create!(
  accommodation: accommodation,
  start_date: Date.today + 2,
  end_date: Date.today + 4,
  guest_name: 'João'
)

Booking.create!(
  accommodation: accommodation,
  start_date: Date.today + 3,
  end_date: Date.today + 6,
  guest_name: 'Maria'
)

puts 'Seeding done!'
