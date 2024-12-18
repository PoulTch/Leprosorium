#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

# before вызывается каждый раз при перезагрузке 
# любой страницы

before do
	# инициализация БД
	init_db
end

# configure вызывается каждый раз при конфигурации приложения:
# когда изменился код программы и перезагрузилась страница

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts 
	(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_date DATA,
    content TEXT
	)'
end	
	
get '/' do
	erb :index			
end

# обработчик get-запроса /new
# (браузер) получает страницу с сервера

get '/new' do
  erb :new
end

# обработчик post-запроса /new
# (браузер) отправляет данные на сервер

post '/new' do
  # получает переменную из post-запроса
  content = params[:content]

  if content.length <= 0
  	@error = 'Type post text'
  	return erb :new
  end

  # сохранение данных в БД

  @db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

  erb "You typed #{content}"
end