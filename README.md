# Atomic Relay Worker

The worker is a device node that connects to an Atomic Relay server and executes jobs.

## Purpose

Workers turn physical devices into message delivery nodes.

Each worker:

* connects to the server via WebSocket
* receives jobs
* executes them using adapters
* reports results

## Adapters

Workers are responsible for running adapters.

An adapter is a small unit that knows how to deliver a message using a specific method.

Example:

* sms_android

Adapters implement a simple interface:

* receive a job
* execute it
* return a result

## Adding a new adapter

1. Create a file under `adapters/`
2. Implement a class with a `perform(job)` method
3. Register it in the adapter registry

No changes to the server are required.

## Android setup (current)

The reference worker runs on Android using Termux.

It uses the device's SIM card to send SMS messages.

## Philosophy

Workers are simple and disposable.

They do not store state.

They execute tasks and report results.
