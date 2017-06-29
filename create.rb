require "stripe"
Stripe.api_key = "sk_test_o1bBWh2kAJPBspQzmf7LAIui"

amount_in_cents = 3000
owner_precentage = 0.4
space_precentage = 0.4

######## Managed Accounts ########


file_space = Stripe::FileUpload.create(
  :file => File.new("/Users/daniel/Desktop/stripe/passport.jpg"),
  :purpose => "identity_document",
)

ba_token_space = Stripe::Token.create(
  :bank_account => {
    :country => "US",
    :currency => "usd",
    :account_holder_name => "Charlotte Thomas",
    :account_holder_type => "company",
    :routing_number => "110000000",
    :account_number => "000123456789",
  },
)

space = Stripe::Account.create(
  :managed => true,
  :country => 'US',
  :email => 'bob@wework.com',
  :legal_entity =>
  {
  	:dob =>
  	{
  		:day => "26",
  		:month => "08",
  		:year => "1990"
  	},
  	:first_name => "Daniel",
  	:last_name => "ThKing",
  	:type => "company",
  	:business_name => "WeWork inc.",
  	:business_tax_id => "666663048",
  		:ssn_last_4 => "1556",
  		:personal_id_number=>"306641556",
  	:address =>{
  		:city => "NYC",
  		:line1 => "219e 25th",
  		:postal_code => "10001",
  		:state => "New York"
  		},
  		:verification=>
  		{
  			:document => file_space.id
  		}
  },
  :tos_acceptance => 
	{
		:date =>  Time.new.to_i,
		:ip => "127.0.0.1"
	},
	:external_account => ba_token_space
)

puts "space id = #{space.id}"


file_owner = Stripe::FileUpload.create(
  :file => File.new("/Users/daniel/Desktop/stripe/passport.jpg"),
  :purpose => "identity_document",
)

ba_token_owner = Stripe::Token.create(
  :bank_account => {
    :country => "US",
    :currency => "usd",
    :account_holder_name => "Charlotte Thomas",
    :account_holder_type => "individual",
    :routing_number => "110000000",
    :account_number => "000123456789",
  },
)


owner = Stripe::Account.create(
  :managed => true,
  :country => 'US',
  :email => 'o@resit.io',
  :legal_entity =>
  {
  	:dob =>
  	{
  		:day => "26",
  		:month => "08",
  		:year => "1990"
  	},
  	:first_name => "Daniel",
  	:last_name => "ThKing",
  	:type => "individual",
  	  		:ssn_last_4 => "1556",
  		:personal_id_number=>"306641556",
  	:address =>{
  		:city => "NYC",
  		:line1 => "219e 25th",
  		:postal_code => "10001",
  		:state => "New York"
  		},
  		:verification=>
  		{
  			:document => file_owner.id
  		}
  },
  :tos_acceptance => 
	{
		:date =>  Time.new.to_i,
		:ip => "127.0.0.1"
	},
	:external_account => ba_token_owner
)

puts "owner id = #{owner.id}"


######## Paying Customers ########

# Create saved CC
mytoken = Stripe::Token.create(
  :card => {
    :number => "4242424242424242",
    :exp_month => 5,
    :exp_year => 2018,
    :cvc => "314"
  },
)

puts "token id = #{mytoken.id}"

# Create customer
paying_customer = Stripe::Customer.create(
	:description => "Customer for mia.thomas@example.com",
  :email => 'bob@example.com',
  :source => mytoken
)

puts "paying customer id = #{paying_customer.id}"


ordernum =  "#{paying_customer.id}-#{space.id}-#{owner.id}"

puts "ordernum = #{ordernum}"

# # Authinticate chrage
# the_auth = Stripe::Charge.create(
#   :amount => amount_in_cents,
#   :currency => "usd",
#   :capture => false,
#   :description => "Authintication with no capture for user with saved CC",
#   :customer => paying_customer.id,
#   :transfer_group => ordernum
# )

# puts "auth id = #{the_auth.id}"




# Create a Charge:
owner_auth = Stripe::Charge.create({
  :amount => (amount_in_cents/2),
  :currency => "usd",
  :capture => false,
  :customer => paying_customer.id,
  :destination => {
    :amount => (amount_in_cents*owner_precentage).to_i,
    :account => owner.id,
  }
})


# Create a Charge:
space_auth = Stripe::Charge.create({
  :amount => (amount_in_cents/2),
  :currency => "usd",
  :capture => false,
  :customer => paying_customer.id,
  :destination => {
    :amount => (amount_in_cents*space_precentage).to_i,
    :account => owner.id,
  }
})


######## Charge ########

# Capture charge
puts "seven days later..."
ch1 = Stripe::Charge.retrieve(owner_auth.id)
the_charge1 = ch1.capture
puts "owner - #{the_charge1.status}"

ch2 = Stripe::Charge.retrieve(space_auth.id)
the_charge2 = ch2.capture
puts "space - #{the_charge2.status}"



# # Create a Transfer to a connected account (later):
# transfer_space = Stripe::Transfer.create({
#   :amount => (amount_in_cents*space_precentage).to_i,
#   :currency => "usd",
#   :destination => space.id,
#   :transfer_group => ordernum,
# })

# # Create a second Transfer to another connected account (later):
# transfer_owner = Stripe::Transfer.create({
#   :amount => (amount_in_cents*owner_precentage).to_i,
#   :currency => "usd",
#   :destination => owner.id,
#   :transfer_group => ordernum,
# })



