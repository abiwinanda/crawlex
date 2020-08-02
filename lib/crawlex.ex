defmodule Crawlex do
  @moduledoc """
  TODO: add some docs
  """

  @doc false
  def gen_report(path \\ "lib") do
    IO.puts("----------------")
    IO.puts("RATIO\t   FILE\t\t\t\t\t\t   LINES   COMMENTS")

    calc_report_data_under_path(path)
    |> Enum.each(fn {file_path, ccr, total_codes, total_comments} ->
      ccr_percentage = float_to_percentage(ccr)
      file_path = format_file_path(file_path)

      print_color =
        cond do
          ccr <= 0.05 -> :red
          ccr <= 0.10 -> :red
          ccr <= 0.15 -> :green
          ccr <= 0.25 -> :green
          true -> :green
        end

      Crawlex.Formatter.print(
        "#{ccr_percentage}\t#{file_path}\t#{total_codes}\t#{total_comments}",
        print_color
      )
    end)

    avg_ccr = calc_ccr_avg_under_path(path)
    avg_ccr_percentage = float_to_percentage(avg_ccr)

    avg_ccr_category =
      cond do
        avg_ccr <= 0.05 -> "HORRIBLE"
        avg_ccr <= 0.10 -> "POOR"
        avg_ccr <= 0.15 -> "AVERAGE"
        avg_ccr <= 0.25 -> "GOOD"
        true -> "EXCELLENT"
      end

    case avg_ccr_category do
      "HORRIBLE" ->
        Crawlex.Formatter.print("[AVG] #{avg_ccr_percentage} (#{avg_ccr_category})", :red)

      "POOR" ->
        Crawlex.Formatter.print("[AVG] #{avg_ccr_percentage} (#{avg_ccr_category})", :red)

      "AVERAGE" ->
        Crawlex.Formatter.print("[AVG] #{avg_ccr_percentage} (#{avg_ccr_category})", :green)

      "GOOD" ->
        Crawlex.Formatter.print("[AVG] #{avg_ccr_percentage} (#{avg_ccr_category})", :green)

      "EXCELLENT" ->
        Crawlex.Formatter.print("[AVG] #{avg_ccr_percentage} (#{avg_ccr_category})", :green)
    end

    IO.puts("----------------")
  end

  @doc false
  def calc_report_data_under_path(path) do
    path
    |> get_all_file_paths_under_path()
    |> Enum.reduce([], fn file_path, ccrs ->
      ccrs ++
        [
          {
            file_path,
            calc_ccr(file_path),
            get_total_line_of_codes(file_path),
            get_total_line_of_comments(file_path)
          }
        ]
    end)
  end

  @doc false
  def calc_ccr_avg_under_path(path) do
    file_path_list = get_all_file_paths_under_path(path)
    total_files = length(file_path_list)

    {total_ccr, total_inf} =
      Enum.reduce(file_path_list, {0, 0}, fn file_path, {total_ccr, total_inf} ->
        case calc_ccr(file_path) do
          "INF" -> {total_ccr, total_inf + 1}
          _ -> {total_ccr + calc_ccr(file_path), total_inf}
        end
      end)

    total_ccr / (total_files - total_inf)
  end

  @doc false
  def get_all_file_paths_under_path(path) do
    path
    |> get_all_paths_under_path()
    |> Enum.reduce([], fn path, files ->
      cond do
        is_elixir_file?(path) -> files ++ [path]
        is_folder?(path) -> files ++ get_all_file_paths_under_path(path)
        true -> files
      end
    end)
  end

  @doc false
  def get_all_paths_under_path(path) do
    Path.wildcard("#{path}/*")
  end

  @doc false
  def calc_ccr(file_path) do
    total_line_of_comments = get_total_line_of_comments(file_path)
    total_line_of_codes = get_total_line_of_codes(file_path)

    if total_line_of_codes == 0 do
      "INF"
    else
      total_line_of_comments / total_line_of_codes
    end
  end

  @doc false
  def get_total_line_of_comments(file_path) do
    codes =
      file_path
      |> File.read!()
      |> String.split("\n", trim: true)

    total_single_line_comments(codes) + total_multi_line_comments(codes)
  end

  @doc false
  def get_total_line_of_codes(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> length()
  end

  #########################
  #         HELPERS       #
  #########################

  defp is_single_line_comment?(line_of_code),
    do: line_of_code =~ "#" and not (line_of_code =~ "\#{")

  defp total_single_line_comments(codes) when is_list(codes) do
    Enum.reduce(codes, 0, fn code, acc ->
      case is_single_line_comment?(code) do
        true -> acc + 1
        false -> acc
      end
    end)
  end

  defp total_multi_line_comments(codes) when is_list(codes) do
    codes
    |> Enum.with_index()
    |> Enum.reduce([], fn {code, index}, acc ->
      case code =~ "\"\"\"" do
        true -> [index | acc]
        false -> acc
      end
    end)
    |> Enum.chunk_every(2)
    |> Enum.reduce(0, fn [upper, lower], acc ->
      acc + upper - lower - 1
    end)
  end

  defp float_to_percentage(float), do: :erlang.float_to_binary(float * 100, decimals: 1) <> "%"

  defp is_folder?(path), do: Path.extname(path) == ""

  defp is_elixir_file?(path), do: Path.extname(path) == ".ex"

  defp format_file_path(file_path) do
    file_path_length = String.length(file_path)

    case file_path_length < 46 do
      true -> file_path <> append_spaces(46 - file_path_length)
      false -> String.slice(file_path, 0..45)
    end
  end

  defp append_spaces(0), do: ""

  defp append_spaces(length) do
    0..(length - 1)
    |> Enum.to_list()
    |> Enum.reduce("", fn _, acc -> acc <> " " end)
  end
end
