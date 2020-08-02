defmodule Mix.Tasks.Crawlex do
  use Mix.Task

  @shortdoc "Calculate comment-to-code ratio of a given path."
  def run(args) do
    cond do
      length(args) == 1 -> calc_ccr(args)
      true -> Crawlex.gen_report()
    end
  end

  defp calc_ccr(path) do
    cond do
      is_folder?(path) -> Crawlex.gen_report(path)
      is_elixir_file?(path) -> ccr_of_a_file(path)
      true -> Crawlex.Formatter.print("ERROR. Not an elixir file.", :red)
    end
  end

  defp ccr_of_a_file(file_path) do
    case File.read(file_path) do
      {:ok, _} ->
        lines = Crawlex.get_total_line_of_codes(file_path)
        comments = Crawlex.get_total_line_of_comments(file_path)
        ratio = Crawlex.calc_ccr(file_path)
        ratio_percentage = Crawlex.float_to_percentage(ratio)

        category =
          cond do
            ratio <= 0.05 -> "HORRIBLE"
            ratio <= 0.10 -> "POOR"
            ratio <= 0.15 -> "AVERAGE"
            ratio <= 0.25 -> "GOOD"
            true -> "EXCELLENT"
          end

        IO.puts("FILE     : #{file_path}")
        IO.puts("LINES    : #{lines}")
        IO.puts("COMMENTS : #{comments}")
        IO.puts("RATIO    : #{ratio_percentage} (#{category})")

      {:error, _} ->
        Crawlex.Formatter.print("ERROR. Unable to find a file with path \"#{file_path}\".", :red)
    end
  end

  defp is_folder?(path), do: Path.extname(path) == ""

  defp is_elixir_file?(path), do: Path.extname(path) == ".ex"
end
