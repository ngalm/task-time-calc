# app.rb
require 'sinatra'
require 'sinatra/activerecord'
require './models/task'

#set :database, {adapter: "sqlite3", database: "task-time-calc.sqlite3"}

configure :development, :production do
    set :database, { adapter: 'sqlite3', database: "time-task-calc-db.sqlite3" }
end

class TaskTimeCalc < Sinatra::Base
    get '/' do
        @tasks = Task.all
        erb :index
    end

    post '/save_task' do
        # Extract form data from params
        new_task_name = params[:new_task_name]
        new_task_start = params[:new_task_start]
        new_task_duration = params[:new_task_duration]
        new_task_notes = params[:new_task_notes]
      
        # Create a new task record in the database
        Task.create(
          name: new_task_name,
          start: Time.parse(new_task_start),  # Parse the time string to a Time object
          duration: new_task_duration.to_i,   # Convert duration to an integer
          notes: new_task_notes
        )
      
        # Redirect to the page where you display tasks
        redirect '/'
      end

    post '/delete_task' do
        task_id = params[:task_id]
        Task.find(task_id).destroy
        redirect '/'
    end
end