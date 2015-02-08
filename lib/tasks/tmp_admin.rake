namespace :db do
  desc "Create temporary admin"
  task tmpadmin: :environment do
    User.create!(first_name: "Admin",
                 last_name: "Temp",
                 email: "tmpadmin@lccdirectory.com",
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
  end
end
