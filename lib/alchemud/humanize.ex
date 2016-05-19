defmodule Alchemud.Humanize do
  @moduledoc """
  Defines functions that change lists of things to a more humanly-readable format/markup.
  """



  @doc """
  Enumerates a list of strings or iodata so the elements are separated by `, `, except for the last element, which is separated by ` and `

  ## Examples
  iex> Alchemud.Humanize.enum(~w{north}) |> IO.iodata_to_binary
  "north"
  iex> Alchemud.Humanize.enum(~w{north south}) |> IO.iodata_to_binary
  "north and south"
  iex> Alchemud.Humanize.enum(~w{north south west}) |> IO.iodata_to_binary
  "north, south and west"
  """
  @spec enum([iodata]) :: iodata
  def enum(list), do: enum(list, [])
  
  def enum([], acc), do: acc
  def enum([last], []), do: [last]
  def enum([last], acc), do: [acc, ' and ', [last]]
  def enum([head|tail], []), do: enum(tail, [head])
  def enum([head|tail], acc), do: enum(tail, acc ++ [', ', [head]])


  def wrap_with_color(str, col) do
    [col, str, :normal]
  end

  def wrap_with_color(str, col, :bright) do
    [col, :bright, str, :normal]
  end

  def underline(str) do
    [:underline, str, :no_underline]
  end


end