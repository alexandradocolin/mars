defmodule App.Robot do
  @moduledoc """
  Module that handles the movement of the robot.
  It takes the grid sizes, then the start position and the set of instructions,
  and moves the robot until it reaches the destination or until it gets lost
  outside of the grid. It prints the destination or the last valid position, along
  with the orientation and, if the position led to an invalid outcome, the word LOST.
  """

  @doc """
  Entry point of the application.
  """
  @spec init() :: atom()
  def init() do
    {m, n} = read_size()
    move(m, n)
  end

  # Function that prompts the user to provide the grid size.
  # It expectes 2 integer values greater than 0, m and n,
  # separated by a space, where m is the x-axis and n is the y-axis.
  # It returns a tuple with the 2 values parsed from string to integer.
  @spec read_size() :: tuple()
  defp read_size() do
    [{m, _}, {n, _}] =
      IO.gets("grid size: ")
      |> String.split()
      |> Enum.map(&Integer.parse(&1))

    {m, n}
  end

  # Recursive function that keeps calling itself as long as the "stop"
  # parameter is not the atom :end. Before calling itself, it requests
  # the instructions for moving/rotating the robot, along with its starting
  # position and orientation, then calls the function that handles the instructions.
  @spec move(integer(), integer(), atom()) :: atom()
  defp move(m, n, stop \\ :contiue) do
    case stop do
      :end ->
        IO.puts("goodbye!")

      _ ->
        stop =
          IO.gets("give instruction set: ")
          |> follow_instructions(m, n)

        move(m, n, stop)
    end
  end

  @spec follow_instructions(String.t(), integer(), integer()) :: atom()
  # Pattern matches against the case where the keyboard input is "end" or "END" and
  # terminates the execution by returning the :end atom.
  defp follow_instructions("end\n", _, _), do: :end
  defp follow_instructions("END\n", _, _), do: :end

  # Extracting the starting coordinates and orientation, as well as the movement
  # instructions, then parsing them as required:
  # x and y need to be integers,
  # new_dir is a character that we use to grab an equivalent integer index,
  # and moves is an array containing all the requested moves, one at a time.
  # The next step is looping through moves until either there are no moves left or
  # the robot gets lost outside the grid.
  # The loop checks whether the current instruction is a rotation or a move-forward instruction:
  # - if rotation, the coordinates stay the same, but the orientation changes
  # - if move-forward, the coordinates change and the orientation stays the same.
  # If the robot moved forward, the new position is validated to check whether the robot
  # got lost or not.
  # The robot is considered lost when is_valid_position? returns false, i.e. when its
  # new coordinates after moving are outside of the grid.
  # It returns the :continue atom, so that the execution of the console application
  # does not terminate.
  defp follow_instructions(instruction_set, m, n) do
    directions = ["N", "E", "S", "W"]
    [x, y, new_dir, moves] = String.split(instruction_set)

    {x, _} = String.replace(x, "(", "") |> Integer.parse()
    {y, _} = y |> Integer.parse()
    new_dir = String.replace(new_dir, ")", "")
    dir_idx = Enum.find_index(directions, &(&1 == new_dir))
    moves = String.graphemes(moves)

    {res_x, res_y, res_dir_idx, res_lost} =
      Enum.reduce_while(moves, {x, y, dir_idx, false}, fn mv, {x1, y1, dir_idx1, lost} ->
        case mv do
          "F" ->
            {x2, y2, dir_idx2} = move_forward(x1, y1, Enum.at(directions, dir_idx1))

            (is_valid_position?(m, n, x2, y2) && {:cont, {x2, y2, dir_idx2, lost}}) ||
              {:halt, {x1, y1, dir_idx1, true}}

          mv ->
            {:cont, {x1, y1, rotate(dir_idx1, mv), lost}}
        end
      end)

    res_lost = (res_lost && " LOST") || ""

    IO.puts("(#{res_x} #{res_y} #{Enum.at(directions, res_dir_idx)})#{res_lost}")

    :continue
  end

  # Pattern matching against the robot's orientation and moving it accordingly:
  # if moving to the N, we increase y by 1;
  # if moving to the S, we decrease y by 1;
  # if moving to the E, we increase x by 1;
  # if moving to the W, we decrease x by 1.
  # Returning a tuple that contains both coordinates and the index of the orientation
  # in the directions array.
  @spec move_forward(integer(), integer(), String.t()) :: tuple()
  defp move_forward(x, y, "N"), do: {x, y + 1, 0}
  defp move_forward(x, y, "S"), do: {x, y - 1, 2}
  defp move_forward(x, y, "E"), do: {x + 1, y, 1}
  defp move_forward(x, y, "W"), do: {x - 1, y, 3}

  # Rotating by 90 degrees into the desired direction.
  # It moves the rotation index in the directions array - hence why it caps it
  # for 2 particular cases:
  # 1. if the robot is facing N (the index is 0) and it wants to rotate left (L)
  # it will result in the robot facing west (W), which has the index 3;
  # 2. if the robot is facing W and it wants to rotate right (R) it will result in
  # the robot facing N, which has the index 0;
  # otherwise the function simply decreases the index if rotating L or increases it
  # if moving R; that's how the index will always be capped between 0 and 3.
  @spec rotate(integer(), String.t()) :: integer()
  defp rotate(0, "L"), do: 3
  defp rotate(dir_idx, "L"), do: dir_idx - 1
  defp rotate(3, "R"), do: 0
  defp rotate(dir_idx, "R"), do: dir_idx + 1

  # Taking the grid sizes and a set of coordinates and checks whether
  # they are still pointing to a valid position on the grid.
  # We say they are valid when the coordinate going east is within
  # 0 and m (so 0 <= x <= m) and the coordinate going north is within
  # 0 and n (so 0 <= y <= n).
  # Pattern matching one coordinate at a time, never both x and y at once.
  @spec is_valid_position?(integer(), integer(), integer(), integer()) :: boolean()
  defp is_valid_position?(m, _n, x, _y) when m < x, do: false
  defp is_valid_position?(_m, n, _x, y) when n < y, do: false
  defp is_valid_position?(_m, _n, x, _y) when x < 0, do: false
  defp is_valid_position?(_m, _n, _x, y) when y < 0, do: false
  defp is_valid_position?(_m, _n, _x, _y), do: true
end
