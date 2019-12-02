input = File.read("input.txt")
  |> (fn file -> elem(file, 1) end).()
  |> String.split("\n", trim: true)
  |> Enum.map(fn x -> String.to_integer(x) end)

defmodule Fuel do
  # Specifically, to find the fuel required for a module, take its mass, divide by three, round down, and subtract 2
  def calculate(input) do
    calculate(input, 0)
  end

  def calculate([], acc) do
    acc
  end

  def calculate([head | tail], acc) do
    calculate_module(head) + acc + calculate(tail, acc)
  end

  def calculate_module(mass) do
    div(mass, 3) - 2
  end
end

IO.puts(Fuel.calculate(input))
