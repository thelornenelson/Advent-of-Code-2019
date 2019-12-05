range = 387638..919123

defmodule Venus_PW_V2 do
  def check(value, curr_seq \\ 0, dd \\ false, not_decreasing \\ false)

  # If last 2 digits are repeated
  def check([_], curr_seq, _dd, not_decreasing) when curr_seq == 1 do
    not_decreasing
  end

  # Check and return findings
  def check([_], _curr_seq, dd, not_decreasing) do
    dd and not_decreasing
  end

  # If digits decrease, pw is immediately invalid
  def check([a | rest], _curr_seq, _dd, _not_decreasing) when a > hd(rest) do
    false
  end

  # End of 2 repeated digits
  def check([a | rest], curr_seq, _dd, _not_decreasing) when a != hd(rest) and curr_seq == 1 do
    check(rest, 0, true, true)
  end

  # Working through repeated digits
  def check([a | rest], curr_seq, dd, _not_decreasing) when a == hd(rest) do
    check(rest, curr_seq + 1, dd, true)
  end

  # Default case, recurse to next digit
  def check([_a | rest], _curr_seq, dd, _not_decreasing) do
    check(rest, 0, dd, true)
  end
end

Stream.map(range, &(Integer.digits(&1)))
  |> Stream.filter(&(Venus_PW_V2.check(&1)))
  |> Enum.to_list
  |> length
  |> IO.inspect(label: "Possible passwords")
