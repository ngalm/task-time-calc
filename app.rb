# app.rb
require 'sinatra'
require 'sinatra/activerecord'
require './models/task'
require './config/environment'
require 'tzinfo'
configure do
    Time.zone = 'America/Los_Angeles' # Example: 'America/New_York'
end

class TaskTimeCalc < Sinatra::Base

    get '/' do
        @tasks = Task.all
        prev_task = @tasks.last  # fetch  prev task's end_time to be new task's start  (if prev exists)
        erb :index, locals: { prev_task: prev_task }
    end

    post '/save_task' do
        new_task_name = params[:new_task_name]
        @tasks = Task.all
        # if a previous task exists, use prev task's end to calc new task's start
        if @tasks.last
            new_task_start_hr, new_task_start_min, new_task_start_ampm = calc_end_time(@tasks.last.start_hr, @tasks.last.start_min, @tasks.last.start_ampm, @tasks.last.duration)
        else
            new_task_start_hr = params[:new_task_start_hr].to_i
            new_task_start_min = params[:new_task_start_min].to_i
            new_task_start_ampm = params[:new_task_start_ampm]
        end
        new_task_start_ampm.upcase  # set constant that ampm value is ALWAYS uppercase, either "AM" or "PM"
        new_task_duration = params[:new_task_duration].to_i
        new_task_notes = params[:new_task_notes]

        # Create a new task record in the database
        Task.create(
          name: new_task_name,
          start_hr: new_task_start_hr,
          start_min: new_task_start_min,
          start_ampm: new_task_start_ampm, 
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

    post '/change_central_start' do
        @tasks = Task.all
        central_start_hr = params[:central_start_hr]
        central_start_min = params[:central_start_min]
        central_start_ampm = params[:central_start_ampm]

        #   if there are tasks to iterate through them
        if @tasks.first
            #   iterate through all tasks changing their start times
            #   set up iteration by changing first task attributes
            @tasks.first.start_hr = central_start_hr
            @tasks.first.start_min = central_start_min
            @tasks.first.start_ampm = central_start_ampm

            prev_task = @tasks.first

            @tasks.each do |task|
                next if task == @tasks.first
                # calc prev_task's end time
                prev_end_hr, prev_end_min, prev_end_ampm = calc_end_time(prev_task.start_hr, prev_task.start_min, prev_task.start_ampm, prev_task.duration)
                
                # update task's start to be prev's end
                task.start_hr = prev_end_hr
                task.start_min = prev_end_min
                task.start_ampm = prev_end_ampm

                prev_task = task
            end
        # if there are no tasks yet, create a new task and only put the start time in ???
        else
            Task.create(
                name: "b",
                start_hr: central_start_hr,
                start_min: central_start_min,
                start_ampm: central_start_ampm, 
                duration: 1,   
                notes: " "
              )
        end

        redirect '/'
    end

    # given a task, format start into appropriate string
    def format_start_time_helper(task)
        "#{task.start_hr}:#{'%02d' % task.start_min} #{task.start_ampm}"    
    end

    # given a task, format end_time into appropriate string
    def format_end_time_helper(task)
        end_hr, end_min, end_ampm = calc_end_time(task.start_hr, task.start_min, task.start_ampm, task.duration)
        "#{end_hr}:#{'%02d' % end_min} #{end_ampm}"
    end

    # given a task's start hour, minute, am/pm, and duration, returns the resulting end hour, minute, am/pm
    def calc_end_time(start_hr, start_min, start_ampm, duration)
        end_hr = start_hr 
        end_min = start_min + duration 
        end_ampm = start_ampm
    
        # Adjust end_hr and end_ampm if end_min exceeds 60
        if end_min >= 60
            end_hr += end_min / 60
            end_min %= 60
        end
    
        if end_hr >= 12
        # change am to pm or pm to am
            if end_ampm == 'PM'
                end_ampm = 'AM'
            else
                end_ampm = 'PM'
            end
            if end_hr > 12
                end_hr -= 12
            end
        end
        return end_hr, end_min, end_ampm
    end
end