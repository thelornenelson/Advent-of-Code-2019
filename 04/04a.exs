range = 387638..919123

defmodule Venus_PW do
  def check(value, dd \\ false, not_decreasing \\ false)

  def check([_a], dd, not_decreasing) do
    dd and not_decreasing
  end

  def check([a | rest], _dd, _not_decreasing) when a == hd(rest) do
    check(rest, true, true)
  end

  def check([a | rest], dd, _not_decreasing) when a < hd(rest) do
    check(rest, dd, true)
  end

  def check(_, _dd, _not_decreasing) do
    false
  end
end

Stream.map(range, &(Integer.digits(&1)))
  |> Stream.filter(&(Venus_PW.check(&1)))
  |> Enum.to_list
  |> length
  |> IO.inspect(label: "Possible passwords")
