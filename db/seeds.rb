Admin.create! do |user|
  user.password = "2QmaKCs2fhU8x9iS0AAL4F7ACR3aZxNdq6WyTEE1"
  user.password_confirmation = "2QmaKCs2fhU8x9iS0AAL4F7ACR3aZxNdq6WyTEE1"
  user.email = "admin@testnet.bitfication.com"
  user.skip_captcha = true
  user.confirmed_at = DateTime.now
end

puts "Created \"admin@testnet.bitfication.com\" user with password \"2QmaKCs2fhU8x9iS0AAL4F7ACR3aZxNdq6WyTEE1\""

Stats.create! do |s|
  s.volume = 0
  s.phigh = 0
  s.plow = 0
  s.pwavg = 0
end

puts "Created zeroed stats."

Currencies.create! do |btc|
  btc.code = "BTC"
  btc.created_at = DateTime.now
  btc.updated_at = DateTime.now
  btc.display = "BTC$"
  btc.flag = ""
  btc.pt = "Bitcoins"
  btc.en = "Bitcoins"
end

puts "Created BTC currency."

Currencies.create! do |brl|
  brl.code = "BRL"
  brl.created_at = DateTime.now
  brl.updated_at = DateTime.now
  brl.display = "R$"
  brl.flag = "pt"
  brl.pt = "Reais"
  brl.en = "Brazilian Real"
end

puts "Created BRL currency."
