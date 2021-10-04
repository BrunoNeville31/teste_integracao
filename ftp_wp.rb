require 'net/ftp'

login = "brunoneville31@universalinformatica.net"
host = "ftp.universalinformatica.net"
pass = "Brunoeisa3101"


Net::FTP.open(host, login, pass) do |ftp|
  ftp.login(user = login, passwd = pass)
  puts "Estamos dentro"
  puts ftp
end