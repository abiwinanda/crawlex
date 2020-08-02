defmodule Crawlex.Formatter do
  @moduledoc false

  @doc false
  def print(content), do: print_white(content)

  @doc false
  def print(content, color) do
    case color do
      :red ->
        print_red(content)

      :green ->
        print_green(content)

      _ ->
        print_white(content)
    end
  end

  def print_white(content), do: IO.puts(IO.ANSI.format([:white, content]))
  def print_green(content), do: IO.puts(IO.ANSI.format([:light_green, content]))
  def print_red(content), do: IO.puts(IO.ANSI.format([:light_red, content]))
end
