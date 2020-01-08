# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

#AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
#
# Gamer.create(phone_number: "256786481312", probability_to_play: rand(0..1.0), segment: ('A'..'F').to_a.sample)
# Gamer.create(phone_number: "256779209096", probability_to_play: rand(0..1.0), segment: ('A'..'F').to_a.sample)
# Gamer.create(phone_number: "256776582036", probability_to_play: rand(0..1.0), segment: ('A'..'F').to_a.sample)
# Gamer.create(phone_number: "256752148252", probability_to_play: rand(0..1.0), segment: ('A'..'F').to_a.sample)
# Gamer.create(phone_number: "256704422320", probability_to_play: rand(0..1.0), segment: ('A'..'F').to_a.sample)
#
# 200.times{
#   gamer = Gamer.create_with(segment: 'A').find_or_create_by(phone_number: "256752148252")
#   data = "184"
#   amount = "1000"
#   reference = rand(36**8).to_s(36).upcase
#   network = "Airtel Uganda"
#   ticket = gamer.tickets.create(phone_number: gamer.phone_number, data: data.gsub(" ", ","), amount: amount.to_i, reference: reference, network: network, first_name: gamer.first_name, last_name: gamer.last_name)
# }
#
# gamer = Gamer.create_with(segment: 'A').find_or_create_by(phone_number: "256786481312")
# data = "802"
# amount = "1000"
# reference = rand(36**8).to_s(36).upcase
# network = "MTN Uganda"
# ticket = gamer.tickets.new(phone_number: gamer.phone_number, data: data.gsub(" ", ","), amount: amount.to_i, reference: reference, network: network, first_name: gamer.first_name, last_name: gamer.last_name)
#
# gamer = Gamer.create_with(segment: 'A').find_or_create_by(phone_number: "256779209096")
#
#
# gamer = Gamer.create_with(segment: 'A').find_or_create_by(phone_number: "256704422320")
#
#
# gamer = Gamer.create_with(segment: 'A').find_or_create_by(phone_number: "256776582036")
#
#
# gamer = Gamer.create_with(segment: 'A').find_or_create_by(phone_number: "256752148252")
