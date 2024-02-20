tasks = [
  {name: 'buy milk', notes: 'almond and whole', duration: 60, start: Time.now},
  {name: 'fold laundry', notes: 'none', duration: 60, start: Time.now}
]

tasks.each do |t|
  Task.create(t)
end