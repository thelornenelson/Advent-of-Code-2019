input = File.read("input.txt")
  |> (fn { _, file } -> file end).()
  |> String.split("\n", trim: true)
  |> Enum.map(fn x -> String.to_integer(x) end)

defmodule Fuel do
  def calculate(modules) do
    calculate(modules, 0)
  end

  def calculate([], acc) do
    acc
  end

  def calculate([head | tail], acc) do
    fuel_for_mass(head) + acc + calculate(tail, acc)
  end

  def fuel_for_mass(mass) do
    min_mass = 6

    if mass > min_mass do
      fuel_mass = div(mass, 3) - 2
      fuel_mass + fuel_for_mass(fuel_mass)
    else
      0
    end
  end
end

IO.puts(Fuel.calculate(input))
