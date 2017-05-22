defmodule Alchemud.Commands.NLTK.PythonWrapper do
  @moduledoc """
  Calls Python code that does NLTK stuff.
  """
  @python_path Path.expand("../../../../python_nltk/", __DIR__)


  use ExActor.GenServer, export: __MODULE__

  defstart start_link do
    IO.puts "Python path: #{@python_path}"
    {:ok, python_pid} = :python.start_link(
      python_path: @python_path |> String.to_charlist,
      python: 'python3'
    )
    initial_state(python_pid)
  end

  defcall recognize(bitstring), state: python_pid do
    res = :python.call(python_pid, :nltk_recognition, :recognize, [bitstring])
    reply(res)
  end

  defcall version, state: python_pid do
    res = :python.call(python_pid, :sys, :"version.__str__", [])
    reply(res)
  end
end
