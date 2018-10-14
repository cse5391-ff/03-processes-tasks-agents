
defmodule Ex02 do

  # For global counter API usage
  @global_count __MODULE__

  ### High level API for counting utilizing Agent functions

  # New counter function that creates new process with initial value as state
  def new_counter(initial_value \\ 0) do
    { :ok, pid } = Agent.start_link(fn -> initial_value end)
    pid
  end

  # Takes state, gets it, returns it, and then post-increments value.
  def next_value(pid) do
    Agent.get_and_update(pid, fn state ->
      {state, state + 1}
    end)
  end

  ### API for global counter implementation
  def new_global_counter() do
    { :ok, pid } = Agent.start_link(fn -> 0 end, name: @global_count)
    pid
  end

  def global_next_value() do
    next_value(@global_count)
  end

end

ExUnit.start()

defmodule Test do
  use ExUnit.Case

  @moduledoc """

  In this exercise you'll use agents to implement the counter.

  You'll do this three times, in three different ways.

  ------------------------------------------------------------------
  ## For each test (3 in all):  10

        6 does the code compile and pass the tests
        2 is the program written in an idiomatic style that uses
          appropriate and effective language and library features
        2 is the program well laid out,  appropriately using indentation,
          blank lines, vertical alignment
  """


  @doc """
  First uncomment this test. Here you will be inserting code
  to create and access the agent inline, in the test itself.

  Replace the placeholders with your code.
  """

  test "counter using an agent" do

    # Here we hardcode a value for zero because we are doing it inline
    # Begins a counter with zero
    { :ok, counter } = Agent.start_link(fn -> 0 end)

    # Gets state of value and post-increments
    value   = Agent.get_and_update(counter, fn state ->
      {state, state + 1}
    end)
    assert value == 0

    # As we can see by the assertion above, the incrementation work
    # begins in the "update" portion after we get the current state.
    value   = Agent.get_and_update(counter, fn state ->
      {state, state + 1}
    end)
    assert value == 1

    # After this point, value should be 2 if we were to get the value.
  end

  @doc """
  Next, uncomment this test, and add code to the Ex02 module at the
  top of this file to make those tests run.
  """

  test "higher level API interface" do
    count = Ex02.new_counter(5)
    assert  Ex02.next_value(count) == 5
    assert  Ex02.next_value(count) == 6
  end

  @doc """
  Last (for this exercise), we'll create a global counter by adding
  two new functions to Ex02. These will use an agent to store the
  count, but how can you arrange things so that you don't need to pass
  that agent into calls to `global_next_value`?
  """

  test "global counter" do
    Ex02.new_global_counter
    assert Ex02.global_next_value == 0
    assert Ex02.global_next_value == 1
    assert Ex02.global_next_value == 2
  end
end






