input = File.read("input.txt")
  |> (fn {:ok, file} -> file end).()
  |> String.replace_suffix("\n", "")
  |> String.split(",", trim: true)
  |> Enum.map(fn x -> String.to_integer(x) end)
  |> Enum.with_index
  |> Enum.reduce(%{}, fn({v, k}, acc) -> Map.put(acc, k, v) end)

defmodule Intcode do
  defp get_value(register, position, 0) do
    # Position mode
    %{^position => target_position} = register
    Map.get(register, target_position)
  end

  defp get_value(register, position, 1) do
    # Immediate mode
    Map.get(register, position)
  end

  defp add(register, instruction, offset) do
    [a, b] = [1, 2]
      |> Enum.map(fn x -> get_value(register, offset + x, Instruction.mode(instruction, x)) end)

    target = Map.get(register, offset + 3)
    %{register | target => a + b}
  end

  defp multiply(register, instruction, offset) do
    [a, b] = [1, 2]
      |> Enum.map(fn x -> get_value(register, offset + x, Instruction.mode(instruction, x)) end)
    target = Map.get(register, offset + 3)
    %{register | target => a * b}
  end

  defp input(register, instruction, offset, input_value) do
      target = Map.get(register, offset + 1)
      %{register | target => input_value}
  end

  defp output(register, instruction, offset) do
    get_value(register, offset + 1, Instruction.mode(instruction, 1))
      |> IO.inspect(label: "Output")
    register
  end

  def run(register, offset \\ 0) do
    %{^offset => instruction} = register
    case Instruction.opcode(instruction) do
      1 ->
        add(register, instruction, offset)
          |> run(offset + 4)
      2 ->
        multiply(register, instruction, offset)
          |> run(offset + 4)
      3 ->
        input_value = 1
        input(register, instruction, offset, input_value)
          |> run(offset + 2)
      4 ->
        output(register, instruction, offset)
          |> run(offset + 2)
      99 ->
        register
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
