input = File.read("input.txt")
  |> (fn { _, file } -> file end).()
  |> String.replace_suffix("\n", "")
  |> String.split(",", trim: true)
  |> Enum.map(fn x -> String.to_integer(x) end)

# Register should probably use a tuple for quicker lookup
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
  def set(register, a, b) do
    List.replace_at(register, 1, a)
      |> List.replace_at(2, b)
  end
end

defmodule Find_inputs do
  def target(register, target, noun \\ 0, verb \\ 0) do
    updated_register = run_inputs(register, noun, verb)
    if hd(updated_register) == target do
      # Input found
      {:ok, noun, verb}
    else
      case {noun, verb} do
        {99, 99} ->
          # No input found
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
