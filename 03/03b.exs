input = File.read("input.txt")
  |> (fn {:ok, file} -> file end).()
  |> String.replace_suffix("\n", "")
  |> String.split("\n", trim: true)
  |> Enum.map(fn x -> String.split(x, ",") end)

defmodule Line do
  def parse(%{x2: x1, y2: y1}, vector, start_path_length) do
    {direction, distance} = String.split_at(vector, 1)
    distance = String.to_integer(distance)
    case direction do
      "U" ->
        %{x1: x1, y1: y1, x2: x1, y2: y1 + distance, orientation: :vertical, end_path_length: start_path_length + distance}
      "D" ->
        %{x1: x1, y1: y1, x2: x1, y2: y1 - distance, orientation: :vertical, end_path_length: start_path_length + distance}
      "R" ->
        %{x1: x1, y1: y1, x2: x1 + distance, y2: y1, orientation: :horizontal, end_path_length: start_path_length + distance}
      "L" ->
        %{x1: x1, y1: y1, x2: x1 - distance, y2: y1, orientation: :horizontal, end_path_length: start_path_length + distance}
    end
  end

  def intersection(%{orientation: a}, %{orientation: b}) when a == b do
    # Parallel lines are considered to never intersect, even if they are collinear
    {:no_intersection, nil}
  end

  def intersection(line_a, line_b) do
    point = if line_a.orientation == :vertical, do: %{x: line_a.x1, y: line_b.y1}, else: %{x: line_b.x1, y: line_a.y1}
    if includes_point?(line_a, point) and includes_point?(line_b, point) do
      path_length_to_intersection = path_length_to_point(line_a, point) + path_length_to_point(line_b, point)
      {:ok, Map.put(point, :length, path_length_to_intersection)}
    else
      {:no_intersection, nil}
    end
  end

  defp path_length_to_point(line, point) do
    line.end_path_length - (abs(line.x2 - point.x) + abs(line.y2 - point.y))
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
    parsed = Line.parse(origin, head, origin.end_path_length)
    acc ++ [parsed] ++ parse(%{x2: parsed.x2, y2: parsed.y2, end_path_length: parsed.end_path_length}, tail, acc)
  end

  def parse([head | tail]) do
    Line.parse(%{x2: 0, y2: 0}, head, 0)
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

Enum.map(input, &(A_Path.parse(&1)))
  |> Intersections.compare_path_list
  |> Enum.filter(fn ({status, _}) -> status == :ok end)
  |> Enum.map(fn({:ok, point}) -> point end)
  |> Enum.min_by(&(&1.length))
  |> IO.inspect

# Note this does not check for path loops/self-intersections which are
# spec'd as possible, but this code proved sufficient for my puzzle input.
