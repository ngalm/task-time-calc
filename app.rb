# app.rb
require 'sinatra'
require 'sinatra/activerecord'
require './models/task'
require './models/central_time'
require './config/environment'

class TaskTimeCalc < Sinatra::Base

    get '/' do
        @central_time = Central_Time.first
        @tasks = Task.all
        prev_task = @tasks.last  # fetch  prev task's end_time to be new task's start  (if prev exists)
        if @central_time 
            central_time_hr = @central_time.central_time_hr
            central_time_min = @central_time.central_time_min
            central_time_ampm = @central_time.central_time_ampm
        else
            central_time_hr = nil
            central_time_min = nil
            central_time_ampm = nil
        end

        erb :index, locals: { prev_task: prev_task,  central_time_hr: central_time_hr, central_time_min: central_time_min, central_time_ampm: central_time_ampm}
    end

    post '/save_task' do
        new_task_name = params[:new_task_name]
        @tasks = Task.all
        @central_time = Central_Time.first

        
        # if a previous task exists, use prev task's end to calc new task's start
        if @tasks.last
            new_task_start_hr, new_task_start_min, new_task_start_ampm = calc_end_time(@tasks.last.start_hr, @tasks.last.start_min, @tasks.last.start_ampm, @tasks.last.duration)
        elsif @central_time
        #   otherwise use the central times
            new_task_start_hr = @central_time.central_time_hr
            new_task_start_min = @central_time.central_time_min
            new_task_start_ampm = @central_time.central_time_ampm
        else
            # TODO: if user hasn't inputed a central_time yet and tries to save first task, send relavent warning
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
        # get task to delete
        to_delete_task = Task.find(params[:task_id])
        to_delete_task_start_hr = to_delete_task.start_hr
        to_delete_task_start_min = to_delete_task.start_min
        to_delete_task_start_ampm = to_delete_task.start_ampm

        # delete the task
        Task.find(params[:task_id]).destroy

        # get prev and next task
        prev_task = Task.where('id < ?', params[:task_id]).order(id: :desc).first
        next_task = Task.where('id > ?', params[:task_id]).order(:id).first

        if prev_task
            # update the remaining tasks using prev task's times
            update_task_times(prev_task)
        elsif next_task
            # if there's no prev task, update next_task to deleted tasks times
            #   and update remaining tasks using next task's times
            next_task.update(
                start_hr: to_delete_task_start_hr,
                start_min: to_delete_task_start_min,
                start_ampm: to_delete_task_start_ampm
            )
            update_task_times(next_task)
        end


        redirect '/'
    end

    post '/change_central_time' do
        tasks = Task.all
        central_time_hr = params[:central_time_hr]
        central_time_min = params[:central_time_min]
        central_time_ampm = params[:central_time_ampm].upcase

        # get rid of old Central_Time record
        Central_Time.delete_all
        #   create an updated Central_Time record
        Central_Time.create(
            central_time_hr: central_time_hr,
            central_time_min: central_time_min,
            central_time_ampm: central_time_ampm, 
        )

        #   if there is/are task/s, update times 
        if tasks.first
            #   change first's start time
            tasks.first.update(
                start_hr: central_time_hr, 
                start_min: central_time_min, 
                start_ampm: central_time_ampm
            )

            # iterate through the rest of the tasks
            update_task_times(tasks.first)

        end

        redirect '/'
    end

    # given a starting task, 
    #   iterate through remaining tasks using starting task's times as a base 
    #       to update and align the rest of the list's tasks  
    def update_task_times(start_task) 
        # get remaining tasks list
        tasks = Task.where('id >= ?', start_task.id).order(:id)
        prev_task = start_task

        tasks.each do |task|
            # don't need to update the starting task's start/end times
            next if task == start_task

            # calc prev_task's end time
            prev_end_hr, prev_end_min, prev_end_ampm = calc_end_time(prev_task.start_hr, prev_task.start_min, prev_task.start_ampm, prev_task.duration)
            
            # update task's start to be prev's end
            task.update(
                start_hr: prev_end_hr,
                start_min: prev_end_min,
                start_ampm: prev_end_ampm
            )

            prev_task = task
        end
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
    
        if end_hr >= 12 && start_hr < 12
        # change am to pm or pm to am
            if end_ampm == 'PM'
                end_ampm = 'AM'
            else
                end_ampm = 'PM'
            end
        end
        if end_hr > 12
            end_hr -= 12
        end

        return end_hr, end_min, end_ampm
    end
end