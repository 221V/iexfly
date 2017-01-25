defmodule Iexfly.Helloplug do
  
  def init() do
    IO.puts "starting up Helloplug..."
  end
  
  def call(conn, _opts) do
    IO.puts "saying hello!"
    Plug.Conn.send_resp(conn, 200, "Hello, world!")
  end
  
end
