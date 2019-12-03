input = File.read("input.txt")
# input = File.read("test.txt")
  |> (fn {:ok, file} -> file end).()
  |> String.replace_suffix("\n", "")
  |> String.split("\n", trim: true)
  |> Enum.map(fn x -> String.split(x, ",") end)

defmodule Line do
  def parse(%{x2: x1, y2: y1}, vector) do
    {direction, distance} = String.split_at(vector, 1)
    distance = String.to_integer(distance)
    case direction do
      "U" ->
        %{x1: x1, y1: y1, x2: x1, y2: y1 + distance, orientation: :vertical}
      "D" ->
        %{x1: x1, y1: y1, x2: x1, y2: y1 - distance, orientation: :vertical}
      "R" ->
        %{x1: x1, y1: y1, x2: x1 + distance, y2: y1, orientation: :horizontal}
      "L" ->
        %{x1: x1, y1: y1, x2: x1 - distance, y2: y1, orientation: :horizontal}
    end
  end

  def intersection(%{orientation: a}, %{orientation: b}) when a == b do
    # Parallel lines are considered to never intersect, even if they are collinear
    {:no_intersection, nil}
  end

  def intersection(line_a, line_b) do
    point = if line_a.orientation == :vertical, do: %{x: line_a.x1, y: line_b.y1}, else: %{x: line_b.x1, y: line_a.y1}
    if includes_point?(line_a, point) and includes_point?(line_b, point) do
      {:ok, point}
    else
      {:no_intersection, nil}
    end
  end

  defp includes_point?(line, point) do
    if is_between?({line.x1, line.x2}, point.x) and is_between?({line.y1, line.y2}, point.y), do: true, else: false
  end

  defp is_between?({a, b}, value) do
    if value <= max(a, b) and value >= min(a, b), do: true, else: false
  end
end

defmodule A_Path do
  def parse(_, [], acc) do
    acc
  end

  def parse(origin, [head | tail], acc) do
    parsed = Line.parse(origin, head)
    acc ++ [parsed] ++ parse(%{x2: parsed.x2, y2: parsed.y2}, tail, acc)
  end

  def parse([head | tail]) do
    Line.parse(%{x2: 0, y2: 0}, head)
      |> parse(tail, [])
  end
end

defmodule Intersections do
  def compare_paths([], _, acc) do
    acc
  end

  def compare_paths([a | a_tail], b_path, acc) do
    acc
      ++ Enum.reduce(b_path, [], fn b, acc -> acc ++ [Line.intersection(a, b)] end)
      ++ compare_paths(a_tail, b_path, acc)
  end

  def compare_path_list(paths, acc \\ [])

  def compare_path_list([], acc) do
    acc
  end

  def compare_path_list([first | rest], acc) do
    acc
      ++ Enum.reduce(rest, [], fn path, acc -> acc ++ compare_paths(first, path, []) end)
      ++ compare_path_list(rest, acc)
  end
end

defmodule Manhattan_Distance do
  def measure(%{x: x, y: y}) do
    abs(x) + abs(y)
  end
end

Enum.map(input, &(A_Path.parse(&1)))
  |> Intersections.compare_path_list
  |> Enum.filter(fn ({status, _}) -> status == :ok end)
  |> Enum.map(fn({:ok, point}) -> point end)
  |> Enum.map(&(Manhattan_Distance.measure(&1)))
  |> Enum.min
  |> IO.inspect
