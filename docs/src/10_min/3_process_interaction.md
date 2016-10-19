# Process Interaction

The [`Process`](@ref) instance can be utilized for process interactions. The two most common examples for this are to wait for another process to finish and to interrupt another process while it is waiting for an event.

## Waiting for a Process

As it happens, a SimJulia [`Process`](@ref) can be used like an event (technically, a [`Process`](@ref) is a subtype of [`AbstractEvent`](@ref)). If you yield it, you are resumed once the process has finished. Imagine a car-wash simulation where cars enter the car-wash and wait for the washing process to finish. Or an airport simulation where passengers have to wait until a security check finishes.

Assume that the car from the last example magically became an electric vehicle. Electric vehicles usually take a lot of time charging their batteries after a trip. They have to wait until their battery is charged before they can start driving again.

This can be modeled with an additional charge process.

A new charge process is started every time the vehicle starts parking. By yielding a [`Process`](@ref) instance, the run process starts waiting for it to finish.
