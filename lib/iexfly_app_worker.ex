defmodule Iexfly.AppWorker do
  
  def start_link do
    #port = System.get_env("PORT") |> String.to_integer
    #port = if port == nil, do: 8080, else: port
    port = 8080
    
    IO.puts("Starting Cowboy on port #{port} ...")
    Plug.Adapters.Cowboy.http(Iexfly.Routing, [], port: port)
  end
  
end
