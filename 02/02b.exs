input = File.read("input.txt")
  |> (fn {:ok, file} -> file end).()
  |> String.replace_suffix("\n", "")
  |> String.split(",", trim: true)
  |> Enum.map(fn x -> String.to_integer(x) end)
  |> Enum.with_index
  |> Enum.reduce(%{}, fn({v, k}, acc) -> Map.put(acc, k, v) end)

defmodule Intcode do
  def op(register, {1, a, b, target}) do
    %{^a => value_a, ^b => value_b} = register
    %{register | target => value_a + value_b}
  end

  def op(register, {2, a, b, target}) do
    %{^a => value_a, ^b => value_b} = register
    %{register | target => value_a * value_b}
  end

  def run(register, offset \\ 0) do
    {op, a, b, target} = get_op(register, offset)
    case op do
      99 ->
        register
      _ ->
        op(register, {op, a, b, target})
          |> run(offset + 4)
    end
  end

  def get_op(register, offset) do
    Enum.map((0..3), fn x -> register[x + offset] end)
      |> List.to_tuple
  end
end

defmodule Set_error do
  def set(register, a, b) do
    Map.put(register, 1, a)
      |> Map.put(2, b)
  end
end

defmodule Find_inputs do
  def target(register, target, noun \\ 0, verb \\ 0) do
    updated_register = run_inputs(register, noun, verb)
    if updated_register[0] == target do
      # Solution found
      {:ok, noun, verb}
    else
      case {noun, verb} do
        {99, 99} ->
          # No solution found
          {:not_found}
        {_, 99} ->
          # Test next noun
          target(register, target, noun + 1, 0)
        _ ->
          # Test next verb
          target(register, target, noun, verb + 1)
      end
    end
  end

  def run_inputs(register, noun, verb) do
    Set_error.set(register, noun, verb)
      |> Intcode.run
  end
end

Find_inputs.target(input, 19690720)
  |> IO.inspect
