
defmodule Ex02 do
  @name __MODULE__

  def new_counter(value \\ 0) do
    { :ok, counter } = Agent.start_link fn -> value end   #create new agent process with a value
    counter                                               #and return the pid
  end

  def next_value(counter_pid) do
    value = Agent.get(counter_pid, fn number -> number end)   #get current value using the pid from the previous method
    Agent.update(counter_pid, fn _ -> value + 1 end)          #add one to value and update the agent
    value                                                     #return the "before +1" value
  end
  
  def new_global_counter() do
    {:ok, _} = Agent.start_link( fn -> 0 end, name: @name)    #create new agent process with global name
  end


  def global_next_value() do
    value = Agent.get(@name, fn number -> number end)   #retrieve pid and value from global variable
    Agent.update(@name, fn _ -> value + 1 end)          #update pid and value with 1
    value                                               #return the value from before 1 was added. 
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
    { :ok, counter } = Agent.start_link fn -> 0 end
  
    Agent.update(counter, fn _ -> 0 end)
    value   = Agent.get(counter, fn number -> number end)
    assert value == 0
  
    Agent.update(counter, fn _ -> value + 1 end)
    value   = Agent.get(counter, fn number -> number end)
    assert value == 1
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
    Ex02.new_global_counter()
    assert Ex02.global_next_value() == 0
    assert Ex02.global_next_value() == 1
    assert Ex02.global_next_value() == 2
  end
end






