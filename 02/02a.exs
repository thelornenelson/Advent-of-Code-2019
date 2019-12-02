input = File.read("input.txt")
  |> (fn { _, file } -> file end).()
  |> String.replace_suffix("\n", "")
  |> String.split(",", trim: true)
  |> Enum.map(fn x -> String.to_integer(x) end)

defmodule Intcode do
  def op(register, {1, a, b, target}) do
    {value_a, _} = List.pop_at(register, a)
    {value_b, _} = List.pop_at(register, b)
    List.replace_at(register, target, value_a + value_b)
  end

  def op(register, {2, a, b, target}) do
    {value_a, _} = List.pop_at(register, a)
    {value_b, _} = List.pop_at(register, b)
    List.replace_at(register, target, value_a * value_b)
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
    {op, _} = List.pop_at(register, 0 + offset)
    {a, _} = List.pop_at(register, 1 + offset)
    {b, _} = List.pop_at(register, 2 + offset)
    {target, _} = List.pop_at(register, 3 + offset)
    {op, a, b, target}
  end
end

defmodule Set_error do
  def set(register, 1202) do
    List.replace_at(register, 1, 12)
      |> List.replace_at(2, 2)
  end
end

Set_error.set(input, 1202)
  |> Intcode.run
  |> IO.inspect
