function produce(v)
  ct = current_task()
  consumer = ct.consumers
  ct.consumers = nothing
  Base.schedule_and_wait(consumer, v)
  return consumer.result
end
produce(v...) = produce(v)

function consume(producer::Task, values...)
  istaskdone(producer) && return producer.value
  ct = current_task()
  ct.result = length(values)==1 ? values[1] : values
  producer.consumers = ct
  Base.schedule_and_wait(producer)
end
