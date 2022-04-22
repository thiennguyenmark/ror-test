mutex = Mutex.new

event_list_1 = [
    [:random, 1, Time.now],
    [:random, 2, Time.now],
    [:random, 3, Time.now]
  ]

event_list_2 = [
  [:random, 3, Time.now],
  [:random, 4, Time.now],
  [:random, 5, Time.now]
]

event_list = [event_list_1, event_list_2]

threads = event_list.map do |events|
  Thread.new do
      mutex.synchronize do
        Analytic.events(events)
      end
  end
end

threads.each(&:join)
