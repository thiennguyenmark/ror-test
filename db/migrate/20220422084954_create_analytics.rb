class CreateAnalytics < ActiveRecord::Migration[5.2]
  def change
    create_table :analytics do |t|
      t.string :event
      t.string :value
      t.datetime :event_time
    end
  end
end
