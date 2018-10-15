defmodule Ex03 do

  @moduledoc """

  `Enum.map` takes a collection, applies a function to each element in
  turn, and returns a list containing the result. It is an O(n)
  operation.

  Because there is no interaction between each calculation, we could
  process all elements of the original collection in parallel. If we
  had one processor for each element in the original collection, that
  would turn it into an O(1) operation.

  However, we don't have that many processors on our machines, so we
  have to compromise. If we have two processors, we could divide the
  map into two chunks, process each independently on its own
  processor, then combine the results.

  You might think this would halve the elapsed time, but the reality
  is that the initial chunking of the collection, and the eventual
  combining of the results both take time. As a result, the speed up
  will be less that a factor of two. If the work done in the mapping
  function is time consuming, then the speedup factor will be greater,
  as the overhead of chunking and combining will be relatively less.
  If the mapping function is trivial, then parallelizing the code will
  actually slow it down.

  Your mission is to implement a function

      pmap(collection, process_count, func)

  This will take the collection, split it into n chunks, where n is
  the process count, and then run each chunk through a regular map
  function, but with each map running in a separate process.

  Useful functions include `Enum.count/1`, `Enum.chunk_every/4` and
  `Enum.concat/1`.

  (If you're runniung an older Elixir, `Enum.chunk_every` may be called `Enum.chunk`.)

  ------------------------------------------------------------------
  ## Marks available: 30

      Pragmatics
        4  does the code compile and run
        5	does it produce the correct results on any valid data

      Tested
      if tests are provided as part of the assignment:
        5	all pass

      Aesthetics
        4 is the program written in an idiomatic style that uses
          appropriate and effective language and library features
        4 is the program well laid out,  appropriately using indentation,
          blank lines, vertical alignment
        3 are names well chosen, descriptive, but not verbose

      Use of language and libraries
        5 elegant use of language features or libraries

  """

  # CHUNKING LOGIC
  # Worst case: n-1 processors at full capacity, 1 very underutilized
  # Want to evenly disperse elements to processes.

  #    enum count   501    502    503    504
  #    processes     3      -      -      -
  #     quotient    167   167.33 167.66  168
  #     remainder    0      1      2      0
  #
  #        p1       167   *168   *168    168
  #        p2       167    167   *168    168
  #        p3       167    167    167    168

  # Divide collection count by processes. Recursively
  # build list taking chunk at a time.
                            
  # when remainder == 0: quotient     -> chunk size
  # when remainder  > 0: quotient + 1 -> chunk size 

  def pmap(collection, process_count, function) do

    mappers = spawn_mappers(function, process_count)

    collection                  # [1, 2, 3, 4, 5, 6] 
    |> to_chunks(process_count) # [[1, 2], [3, 4], [5, 6]]
    |> delegate_chunks(mappers) # map([1,2]) ; map([3,4]) ; map([5,6])
    
    mappers                     # [pid1, pid2, pid3]
    |> combine_results()        # [[1*, 2*], [3*, 4*], [5*, 6*]]  
    |> List.flatten()           # [1*, 2*, 3*, 4*, 5*, 6*]   

  end

  def mapper(func_to_apply) do
    
    receive do
      { :map, requester, list } ->
        mapped_list = list |> Enum.map(func_to_apply)
        send(requester, {:mapped, self(), mapped_list})
    end

  end

  defp spawn_mappers(_function, _process_count = 0) do
    []
  end

  defp spawn_mappers(function, process_count) do

    mapper_pid = spawn(Ex03, :mapper, [ function ])

    [ mapper_pid | spawn_mappers(function, process_count - 1) ]

  end

  defp to_chunks(collection, process_count) do

    state = collection |> build_chunking_state(process_count)

    collection 
    |> split_into_chunks(state)

  end

  defp build_chunking_state(collection, _process_count = 0) do

    %{
      size:          collection |> Enum.count(),
      process_count: 0
    }

  end

  defp build_chunking_state(collection, process_count) do

    collection_size = collection |> Enum.count()

    %{
      size:          collection_size,
      remainder:     collection_size |> rem(process_count),
      quotient:      collection_size |> div(process_count),
      process_count: process_count
    }

  end

  defp split_into_chunks(_collection, %{process_count: count, size: size}) 
    when count == 0 or size == 0
  do
    []
  end

  defp split_into_chunks(collection, state = %{}) do

    chunk_size = get_chunk_size(state)
    { chunk, new_collection } = collection |> Enum.split(chunk_size)

    new_state = new_collection |> build_chunking_state(state.process_count - 1)

    [ chunk | split_into_chunks(new_collection, new_state) ]

  end

  defp get_chunk_size(%{quotient: quotient, remainder: 0}), do: quotient
  defp get_chunk_size(%{quotient: quotient}),               do: quotient + 1

  defp delegate_chunks([], []) do
    :delegation_complete
  end

  defp delegate_chunks([ chunk | rest_of_chunks ], [ mapper | rest_of_mappers ]) do
    mapper |> send({:map, self(), chunk})
    delegate_chunks(rest_of_chunks, rest_of_mappers)
  end

  defp combine_results([]) do
    []
  end

  defp combine_results([mapper | rest_of_mappers]) do

    receive do
      {:mapped, ^mapper, mapped_chunk} -> 
        [mapped_chunk | combine_results(rest_of_mappers)]
    end

  end

end


ExUnit.start
defmodule TestEx03 do
  use ExUnit.Case
  import Ex03

  test "pmap with 1 process" do
    assert pmap(1..10, 1, &(&1+1)) == 2..11 |> Enum.into([])
  end

  test "pmap with 2 processes" do
    assert pmap(1..10, 2, &(&1+1)) == 2..11 |> Enum.into([])
  end

  test "pmap with 3 processes (doesn't evenly divide data)" do
    assert pmap(1..10, 3, &(&1+1)) == 2..11 |> Enum.into([])
  end

  # The following test will only pass if your computer has
  # multiple processors.
  test "pmap actually reduces time" do
    range = 1..1_000_000
    # random calculation to burn some cpu
    calc  = fn n -> :math.sin(n) + :math.sin(n/2) + :math.sin(n/4)  end

    { time1, result1 } = :timer.tc(fn -> pmap(range, 1, calc) end)
    { time2, result2 } = :timer.tc(fn -> pmap(range, 2, calc) end)

    assert result2 == result1
    assert time2 < time1 * 0.8
  end

end
