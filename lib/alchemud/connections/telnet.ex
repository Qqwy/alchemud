defmodule Alchemud.Connections.Telnet do



  start(port \\ 23), gen_server_opts: [name: __MODULE__] do
    {:ok, listen} = :gen_tcp.listen(port, [:binaryy, {:active, true}])
    {:ok, socket} = gen_tcp.accept(listen)
    gen_tcp.close(listen)
    IO.puts "[#{self}] Starting up `telnet` on port #{port}"
    initial_state(port)
  end


end