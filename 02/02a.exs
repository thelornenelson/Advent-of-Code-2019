input = File.read("input.txt")
  |> (fn { _, file } -> file end).()
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
    if op == 99 do
      register
    else
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

Set_error.set(input, 12, 2)
  |> Intcode.run
  |> IO.inspect
