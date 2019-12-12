input = File.read("input.txt")
  |> (fn {:ok, file} -> file end).()
  |> String.replace_suffix("\n", "")
  |> String.split(",", trim: true)
  |> Enum.map(fn x -> String.to_integer(x) end)
  |> Enum.with_index
  |> Enum.reduce(%{}, fn({v, k}, acc) -> Map.put(acc, k, v) end)

defmodule Intcode do
  defp get_input() do
    IO.gets("Provide an input: ")
      |> String.replace_suffix("\n", "")
      |> String.to_integer
  end

  # Position mode
  defp get_value(register, position, 0) do
    %{^position => target_position} = register
    Map.get(register, target_position)
  end

  # Immediate mode
  defp get_value(register, position, 1) do
    Map.get(register, position)
  end

  defp get_n_values(register, offset, instruction, n) do
    Enum.map(1..n, fn x -> get_value(register, offset + x, Instruction.mode(instruction, x)) end)
  end

  # Add
  defp op({register, offset}, 1, instruction) do
    [a, b] = get_n_values(register, offset, instruction, 2)
    target = Map.get(register, offset + 3)
    {%{register | target => a + b}, offset + 4}
  end

  # Multiply
  defp op({register, offset}, 2, instruction) do
    [a, b] = get_n_values(register, offset, instruction, 2)
    target = Map.get(register, offset + 3)
    {%{register | target => a * b}, offset + 4}
  end

  # Input
  defp op({register, offset}, 3, _) do
    target = Map.get(register, offset + 1)
    {%{register | target => get_input()}, offset + 2}
  end

  # Output
  defp op({register, offset}, 4, instruction) do
    get_value(register, offset + 1, Instruction.mode(instruction, 1))
      |> IO.inspect(label: "Output")
    {register, offset + 2}
  end

  # jump-if-true
  defp op({register, offset}, 5, instruction) do
    [test, target] = get_n_values(register, offset, instruction, 2)
    case test do
      0 ->
        {register, offset + 3}
      _ ->
        {register, target}
    end
  end

  # jump-if-false
  defp op({register, offset}, 6, instruction) do
    [test, target] = get_n_values(register, offset, instruction, 2)
    case test do
      0 ->
        {register, target}
      _ ->
        {register, offset + 3}
    end
  end

  # Less than
  defp op({register, offset}, 7, instruction) do
    [a, b] = get_n_values(register, offset, instruction, 2)
    target = Map.get(register, offset + 3)
    cond do
      a < b ->
        {%{register | target => 1}, offset + 4}
      true ->
        {%{register | target => 0}, offset + 4}
    end
  end

  # Equal
  defp op({register, offset}, 8, instruction) do
    [a, b] = get_n_values(register, offset, instruction, 2)
    target = Map.get(register, offset + 3)
    cond do
      a == b ->
        {%{register | target => 1}, offset + 4}
      true ->
        {%{register | target => 0}, offset + 4}
    end
  end

  def run(register) do
    next_op({register, 0})
  end

  defp next_op({register, offset}) do
    %{^offset => instruction} = register
    opcode = Instruction.opcode(instruction)
    case opcode do
      99 ->
        register
      _ ->
        op({register, offset}, opcode, instruction)
          |> next_op
    end
  end
end

defmodule Instruction do
  defp pad_left(instruction) do
    instruction + 100_000
     |> Integer.digits
     |> tl
  end

  def opcode(instruction) do
    pad_left(instruction)
     |> Enum.take(-2)
     |> Integer.undigits
  end

  def mode(instruction, param) do
    pad_left(instruction)
      |> Enum.take(3)
      |> Enum.reverse
      |> Enum.at(param - 1)
  end
end

# Simple tests for Instruction
# Instruction.opcode(1002)
#   |> IO.inspect(label: "Should be 2")

# Instruction.mode(3, 1)
#   |> IO.inspect(label: "Should be 0")

# Instruction.mode(1002, 1)
#   |> IO.inspect(label: "Should be 0")

# Instruction.mode(1002, 2)
#   |> IO.inspect(label: "Should be 1")

# Instruction.mode(1002, 3)
#   |> IO.inspect(label: "Should be 0")

# Instruction.mode(11002, 3)
#   |> IO.inspect(label: "Should be 1")

Intcode.run(input)
