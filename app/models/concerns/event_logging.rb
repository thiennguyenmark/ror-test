module EventLogging
  def event(event, value, event_time = Time.now)
    raise ArgumentError "event is not a Symbol" unless event.is_a?(Symbol)
    raise ArgumentError "value is not a String" unless value.is_a?(String)

    self.connection
    self.create!(event: event.to_s, value: value, event_time: event_time)
  end

  def events(record_list)
    raise ArgumentError "record_list not an Array of Hashes" unless record_list.is_a?(Array)
    key_list, value_list = convert_record_list(record_list)

    sql = "INSERT INTO #{self.table_name} (#{key_list.join(", ")}) VALUES #{value_list.map {|rec| "(#{rec.join(", ")})" }.join(" ,")}"
    self.connection.insert(sql)
  end

  private

  def convert_record_list(value_list)
    key_list = %w[event value event_time]
    values = []

    value_list.each do |record|
      raise ArgumentError "too many values" if record.size > 3 || record.size <=1

      item = if record.size === 3
                record
              else
                record.push(Time.now)
             end

      convert_item = item.map do |it|
        it.to_s
        ActiveRecord::Base.connection.quote(it)
      end

      values.push(convert_item)
    end

    return [key_list, values]
  end
end
