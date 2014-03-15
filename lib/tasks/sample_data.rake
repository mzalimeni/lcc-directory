namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    User.create!(first_name: "Michael",
                 last_name: "Zalimeni",
                 email: "admin@lccdirectory.foo",
                 street_address: "203 Turnstone Rd. Apt. B",
                 city: "Columbus",
                 state: "OH",
                 postal_code: "43235",
                 mobile_phone: "3362225555",
                 home_phone: "9194442222",
                 work_phone: "6142227777",
                 primary_phone: 0,
                 birthday: Time.local(1989, 10, 24),
                 directory_public: true,
                 password: "admin1",
                 password_confirmation: "admin1",
                 admin: true)
    99.times do |n|
      first_name  = Faker::Name.first_name
      last_name  = Faker::Name.last_name
      email = "example-#{n+1}@lccdirectory.foo"
      street_address = Faker::Address.street_address
      city = Faker::Address.city
      state = Faker::Address.state_abbr
      postal_code = Faker::Address.postcode
      mobile_number = rand(6141000000..6149999999)
      home_phone = rand(6141000000..6149999999)
      work_phone = rand(6141000000..6149999999)
      primary_phone = rand(0..2)
      birthday = Time.local(rand(1960..2005),rand(1..12),rand(1..28))
      directory_public = (rand(0..15) === 0)
      password  = "password"
      User.create!(first_name: first_name,
                   last_name: last_name,
                   email: email,
                   street_address: street_address,
                   password: password,
                   password_confirmation: password)
    end
  end
end
