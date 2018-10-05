
defmodule Ex02 do

  ### Counter API ###

  def new_counter(initial_value \\ 0) do

    { :ok, counter } = fn -> initial_value end |> Agent.start_link()

    counter

  end

  def next_value(counter) do

    get_and_increment_val = fn current_val -> { current_val, current_val + 1 } end 
    
    counter 
    |> Agent.get_and_update(get_and_increment_val)

  end

  ### Global Counter ###

  def new_global_counter() do

  end

  def global_next_value() do

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

    # Initialize counter
    { :ok, counter } = Agent.start_link(fn -> 0 end)
  
    # Agent.get_and_update
    get_and_increment_val = fn current_val -> { current_val, current_val + 1 } end 
    
    value = counter |> Agent.get_and_update(get_and_increment_val)
    assert value == 0
  
    # Agent.get
    get_val = fn current_val -> current_val end

    value = counter |> Agent.get(get_val)
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
    Ex02.new_global_counter
    assert Ex02.global_next_value == 0
    assert Ex02.global_next_value == 1
    assert Ex02.global_next_value == 2
  end
  
end






