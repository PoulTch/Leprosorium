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
    content TEXT,
    author TEXT
	)'

		@db.execute 'CREATE TABLE IF NOT EXISTS Comments 
	(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_date DATA,
    content TEXT,
    post_id INTEGER
	)'
end	
	
get '/' do
	# выбираем список постов из БД

	@results = @db.execute 'select * from Posts order by id desc'

	erb :index			
end

# обработчик get-запроса /new
# (браузер) получает страницу с сервера

get '/new' do
  erb :new
end

# обработчик post-запроса /new
# (браузер отправляет данные на сервер)

post '/new' do
  # получает переменную из post-запроса
  content = params[:content]
  author = params[:author]

  hh = {:author => 'Type your name', 
  			:content => 'Type post text',                              	                                  
				}                                                
                                                                 
	@error = hh.select {|key,_| params[key] == ""}.values.join(", ") 
                                                                 
	if @error != ''                                                  
		return erb :new                                        
	end
                                                              


  # сохранение данных в БД

  @db.execute 'insert into Posts 
  (
  content, 
  created_date, 
  author
  ) 
  values 
  (
  ?, 
  datetime(), 
  ?)', [content, author]

  # перенаправляем на главную страницу

  redirect to '/'  
end



get '/details/:post_id' do

	# получаем парамер, id поста, из URL
	post_id = params[:post_id]

	# получаем список постов (у нас будет только один пост)
	results = @db.execute 'select * from Posts where id = ?', [post_id]

	# выбираем этот один пост в переменную @row
	@row = results[0]

	# выбираем комментарии для нашего поста
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	# возвращаем представление details.erb
	erb :details
end

# обработчик post-запроса /details/...
# (браузер отправляет данные на сервер, мы их принимаем)

post '/details/:post_id' do

	# получаем парамер, id поста, из URL
	post_id = params[:post_id]

	# получает переменную из post-запроса
  content = params[:content]

  if content.length <= 0
  	@error = 'Type comment text'
  	return erb :new
  end

    # сохранение данных в БД

  @db.execute 'insert into Comments 
  (
  		content,
  		created_date,
  		post_id
  ) 
  		values
  (
  		?, 
  		datetime(),
  		?
  )', [content, post_id]

  # перенаправляем на страницу поста

  redirect to('/details/' + post_id)

end