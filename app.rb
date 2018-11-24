#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

def get_db
  SQLite3::Database.new 'BarberShop'
end

configure do
  db = get_db
  db.execute 'CREATE TABLE IF NOT EXISTS `Users` (
	  `id`	INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
	  `Name`	TEXT,
	  `Phone`	TEXT,
	  `Time`	TEXT,
	  `Barber`	TEXT,
	  `Color`	TEXT
  )'
end

get '/' do
  erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"
end

get '/about' do
  erb :about
end

get '/visit' do
  erb :visit
end

get '/contacts' do
  erb :contacts
end

post '/contacts' do
  @email = params[:email]
  @area = params[:area]
  @name = params[:name]

  Pony.mail({
                :to => @email,
                :body => @area,
                :via => :smtp,
                :via_options => {
                    :address        => 'smtp.gmail.com',
                    :port           => '587',
                    :enable_starttls_auto => true,
                    :user_name      => 'shodkvest@gmail.com',
                    :password       => 'ujkjdfkjvfkrf',
                    :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
                    :domain         => "localhost.localdomain" # the HELO domain provided by the client to the server
                }
            })

  f = File.open './public/contacts.txt', 'a'
  f.write "#{@email}, #{@area}\n"
  f.close

  erb :contacts
end

post '/visit' do
  @name = params[:username]
  @phone = params[:phone]
  @time = params[:time]
  @barber = params[:barber]
  @color = params[:color]

  #Для каждой пары ключ-значение
  hash = { :username => 'Enter name',
           :phone => 'Enter number phone',
           :time => 'Enter time'}

  hash.each do |key, value|
    if params[key] == ''
      @error = value

      return erb :visit
    end
  end

  # @error = hash.select {|key,_| params[key] == ""}.values.join(", ")
  #
  # if @error != ''
  #   return erb :visit
  # end

  db = get_db
  db.execute 'insert into Users(name, phone, time, barber, color) values(?, ?, ?, ?, ?)',
              [@name, @phone, @time, @barber, @color]

  f = File.open './public/users.txt', 'a'
  f.write "#{@name}, #{@phone}, #{@time}, #{@barber}, #{@color}\n"
  f.close

  erb :visit
end