namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    User.create!(first_name: "Michael",
                 last_name: "Zalimeni",
                 email: "admin@lccdirectory.foo",
                 street_address: "123 Directory Dr. Apt. 9",
                 city: "Columbus",
                 state: "OH",
                 postal_code: "43235",
                 mobile_phone: "3362225555",
                 home_phone: "9194442222",
                 work_phone: "9192227777",
                 birthday: Time.local(1960, 12, 12),
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
      state = %w(AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN
                MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA
                WA WV WI WY).sample
      postal_code = Faker::Address.postcode
      mobile_phone = rand(6141000000..6149999999)
      home_phone = rand(6141000000..6149999999)
      work_phone = rand(6141000000..6149999999)
      birthday = Time.local(rand(1960..2005),rand(1..12),rand(1..28))
      directory_public = (rand(0..15) === 0)
      password  = "password"
      User.create!(first_name: first_name,
                   last_name: last_name,
                   email: email,
                   street_address: street_address,
                   city: city,
                   state: state,
                   postal_code: postal_code,
                   mobile_phone: mobile_phone,
                   home_phone: home_phone,
                   work_phone: work_phone,
                   birthday: birthday,
                   directory_public: directory_public,
                   password: password,
                   password_confirmation: password)
    end
  end
end
