defmodule Iexfly.Router do
  
  defmacro __using__(_opts) do
    quote do
      def init(options) do
        options
      end

      def call(conn, _opts) do
        route(conn.method, conn.path_info, conn)
      end
    end
  end
  
end

defmodule Iexfly.Routing do
  import Plug.Conn
  use Iexfly.Router
  
  def route("GET", [], conn) do
    IO.puts("GET /")
    conn |> send_resp(200, "Hello, world!")
  end

  def route("GET", ["hello", thing], conn) do
    IO.puts("GET /hello/#{thing}")
    conn |> send_resp(200, "Hello, #{thing}!")
  end

  def route("GET", ["cat", cat_id], conn) do
    IO.puts("GET /cat/#{cat_id}")
    conn |> send_resp(200, "You requested cat #{cat_id}")
  end

  def route(method, path, conn) do
    IO.puts("#{String.upcase(method)} /#{path}")
    conn |> send_resp(404, "Not found.")
  end
  
end
