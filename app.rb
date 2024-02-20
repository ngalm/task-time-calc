# app.rb
require 'sinatra'
require 'sinatra/activerecord'
require './models/task'

set :database, {adapter: "sqlite3", database: "task-time-calc.sqlite3"}
class TaskTimeCalc < Sinatra::Base
    get '/' do
        @tasks = Task.all
        erb :index
    end
end