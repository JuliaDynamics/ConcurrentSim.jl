Process Interaction
-------------------

Discrete event simulation is only made interesting by interactions between processes.

So this section is about:

  - Sleep until woken up
  - Waiting for another process to terminate
  - Interrupting another process

The first two items were already covered in the previous section, but they are included here for the sake of completeness.

Another possibility for processes to interact are resources. They are discussed in the next section.


Sleep until woken up
~~~~~~~~~~~~~~~~~~~~

Imagine you want to model an electric vehicle with an intelligent battery-charging controller. While the vehicle is driving, the controller can be passive but needs to be reactivate once the vehicle is connected to the power grid in order to charge the battery.

In SimJulia, you can accomplish that with a simple, shared Event::

  using SimJulia

  type EV
    bat_ctrl_reactivate :: Event
    function EV(env::Environment)
      ev = new()
      ev.bat_ctrl_reactivate = Event(env)
      Process(env, drive, ev)
      Process(env, bat_ctrl, ev)
      return ev
    end
  end

  function drive(env::Environment, ev::EV)
    while true
      yield(Timeout(env, 20.0*rand()+20.0))
      println("Start parking at $(now(env))")
      succeed(ev.bat_ctrl_reactivate)
      ev.bat_ctrl_reactivate = Event(env)
      yield(Timeout(env, 300.0*rand()+60.0))
      println("Stop parking at $(now(env))")
    end
  end

  function bat_ctrl(env::Environment, ev::EV)
    while true
      println("Bat. ctrl. passivating at $(now(env))")
      yield(ev.bat_ctrl_reactivate)
      println("Bat. ctrl. reactivated at $(now(env))")
      yield(Timeout(env, 60*rand()+30))
    end
  end

  env = Environment()
  ev = EV(env)
  run(env, 150.0)

The process function :func:`bat_ctrl()` just waits for a normal event.


Waiting for another process to terminate
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The example above has a problem: it may happen that the vehicles wants to park for a shorter duration than it takes to charge the battery (this is the case if both, charging and parking would take 60 to 90 minutes).

To fix this problem we have to slightly change our model. A new :func:`bat_ctrl()` will be started every time the EV starts parking. The EV then waits until the parking duration is over and until the charging has stopped::

  using SimJulia

  function drive(env::Environment)
    while true
      yield(Timeout(env, 20.0*rand()+20.0))
      println("Start parking at $(now(env))")
      charging = Process(env, bat_ctrl)
      parking = Timeout(env, 300.0*rand()+60.0)
      yield(charging & parking)
      println("Stop parking at $(now(env))")
    end
  end

  function bat_ctrl(env::Environment)
    println("Bat. ctrl. started at $(now(env))")
    yield(Timeout(env, 60*rand()+30))
    println("Bat. ctrl. done at $(now(env))")
  end

  env = Environment()
  Process(env, drive)
  run(env, 310.0)

Again, nothing new and special is happening. SimJulia processes are subtypes of :class:`BaseEvent`, so you can yield. You can also wait for two events at the same time by concatenating them with ``&``.


Interrupting another process
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As usual, another problem can be considered: Imagine, a trip is very urgent, but with the current implementation, we always need to wait until the battery is fully charged. If we could somehow interrupt that ...

Fortunate coincidence, there is indeed a way to do exactly this. You can call the event constructor :func:`Interruption(proc::Process, cause::Any=nothing) <Interrupt>`. This will throw an :class:`InterruptException` into that process, resuming it immediately::

  using SimJulia

  function drive(env::Environment)
    while true
      yield(Timeout(env, 20.0*rand()+20.0))
      println("Start parking at $(now(env))")
      charging = Process(env, bat_ctrl)
      parking = Timeout(env, 60.0)
      yield(charging | parking)
      if !done(charging)
        yield(Interruption(charging, "Need to go!"))
      end
      println("Stop parking at $(now(env))")
    end
  end

  function bat_ctrl(env::Environment)
    println("Bat. ctrl. started at $(now(env))")
    try
      yield(Timeout(env, 60*rand()+30))
      println("Bat. ctrl. done at $(now(env))")
    catch exc
      println("Bat. ctrl. Interrupted at $(now(env)), msg: $(msg(exc))")
    end
  end

  env = Environment()
  Process(env, drive)
  run(env, 100.0)

What the event constructor :func:`Interruption(proc::Process, cause::Any=nothing) <Interrupt>` actually does is scheduling an interrupt event for immediate execution. If this event is executed it will remove the victim process’ :func:`proc.resume(ev::AbstractEvent) <proc.resume>` from the callbacks of the event that it is currently waiting for. Following that it will throw an :class:`InterruptException` into the process function.

An interrupt event constructor must be yielded immediately. The interrupt event has a higher priority than all other events and only after the scheduling of the interrupt event, the interrupting process can be resumed.

The cause of the interrupt can be found by calling the function :func:`cause(inter::InterruptException) <cause>`.

Since nothing special has been done to the original target event of the process, the interrupted process can yield the same event again after catching the Interrupt – Imagine someone waiting for a shop to open. The person may get interrupted by a phone call. After finishing the call, he or she checks if the shop already opened and either enters or continues to wait.
