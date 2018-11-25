#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

def is_exists? db, name
  db.execute('SELECT * FROM Barbers WHERE name = ?', [name]).length > 0
end

def seed_db db, barbers
  barbers.each do |item|
    if !is_exists? db, item
      db.execute 'INSERT INTO Barbers(Name) VALUES(?)', [item]
    end
  end
end

def get_db
  db = SQLite3::Database.new 'BarberShop'
  db.results_as_hash = true
  return db
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

  db.execute 'CREATE TABLE IF NOT EXISTS `Barbers` (
	  `id`	INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
	  `Name`	TEXT
  )'

  seed_db db, ["Walter", "Jessie", "Gus"]
end

get '/' do
  erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"
end

get '/about' do
  erb :about
end

get '/visit' do
  db = get_db
  @result = db.execute 'SELECT * FROM Barbers'

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

get '/showusers' do
  @mas = []
  @db_value = Hash.new

  db = get_db
  db.execute 'select * from Users order by id desc --' do |row|
    @mas << row
  end

  erb :showusers
end