input = File.read("input.txt")
  |> (fn {:ok, file} -> file end).()
  |> String.replace_suffix("\n", "")
  |> String.split(",", trim: true)
  |> Enum.map(fn x -> String.to_integer(x) end)
  |> List.to_tuple

defmodule Intcode do
  def op(register, {1, a, b, target}) do
    value_a = elem(register, a)
    value_b = elem(register, b)
    put_elem(register, target, value_a + value_b)
  end

  def op(register, {2, a, b, target}) do
    value_a = elem(register, a)
    value_b = elem(register, b)
    put_elem(register, target, value_a * value_b)
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
    op = get_elem(register, 0 + offset)
    a = get_elem(register, 1 + offset)
    b = get_elem(register, 2 + offset)
    target = get_elem(register, 3 + offset)
    {op, a, b, target}
  end

  def get_elem(register, offset) when offset >= tuple_size(register) do
    nil
  end

  def get_elem(register, offset) do
    elem(register, offset)
  end
end

defmodule Set_error do
  def set(register, a, b) do
    put_elem(register, 1, a)
      |> put_elem(2, b)
  end
end

defmodule Find_inputs do
  def target(register, target, noun \\ 0, verb \\ 0) do
    updated_register = run_inputs(register, noun, verb)
    if elem(updated_register, 0) == target do
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
