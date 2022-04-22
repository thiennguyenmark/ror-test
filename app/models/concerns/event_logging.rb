module EventLogging
  def event(event, value, event_time = Time.now)
    raise ArgumentError "event is not a Symbol" unless event.is_a?(Symbol)
    raise ArgumentError "value is not a String" unless value.is_a?(String)

    self.connection
    self.create!(event: event.to_s, value: value, event_time: event_time)
  end
end
