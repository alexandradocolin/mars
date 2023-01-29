# App

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `iex -S mix phx.server`/`iex.bat -S mix phx.server` (Mac/Windows).

To run the console application:
  * Type `App.Robot.init()` to start the console application
  * When prompted, input the grid size (`m` and `n`), separated by space (e.g. `4 8`, where 4 is the x-axis size and 8 is the y-axis size); both values have to be positive integers greater than 0 (please!)
  * Next, you'll be prompted to input a set of instructions that follows the structure `(<start_x_coordinate> <start_y_coordinate> <start_orientation>) <series_of_directions>`; `start_x_coordinate` is a positive integer
  between 0 and m, `start_y_coordinate` ranges between 0 and `n`, `start_orientation` is one of `N`, `E`, `S` and `W`, and `series_of_directions` is a string, without any separators, that contains any of the characters `L`,
  `R` and `F` - `L` requests a 90 degree rotation to the left, `R` a 90 degree rotation to the right and `F` requests a 1-step movement in the last given direction, the start direction being `start_orientation`
  * The application will run as long as you don't purposefully crash it by providing values that don't match the above requirements
  * To stop the application from running, type either `end` or `END` and hit Enter.

