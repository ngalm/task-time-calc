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
        default_start_time = @tasks.last&.end_time  # fetch  prev task's end_time to be new task's start  (if prev exists)
        erb :index, locals: { default_start_time: default_start_time }
    end

    post '/save_task' do
        new_task_name = params[:new_task_name]

        if params[:new_task_start].to_s.empty? #if the user has not provided a start time...
            new_task_start = @tasks.last.end_time
        else
            new_task_start = DateTime.strptime(params[:new_task_start], "%I:%M %p") # otherwise, use the user's inputted start time
        end
        new_task_duration = params[:new_task_duration].to_i
        new_task_notes = params[:new_task_notes]

        end_time = new_task_start + Rational(new_task_duration, 1440)

        # Create a new task record in the database
        Task.create(
          name: new_task_name,
          start: new_task_start,  
          end_time: end_time,
          duration: new_task_duration,   
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