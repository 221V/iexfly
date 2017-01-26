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
  
  require EEx # you have to require EEx before using its macros outside of functions
  
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

  def route("GET", ["user", user_id], conn) do
    IO.puts("GET /user/#{user_id}")
    page_contents = EEx.eval_file("lib/templates/show_user.eex", [user_id: user_id])
    conn |> Plug.Conn.put_resp_content_type("text/html") |> Plug.Conn.send_resp(200, page_contents)
  end

  EEx.function_from_file :defp, :template_show_dog, "lib/templates/show_dog.eex", [:dog_id]
  def route("GET", ["dog", dog_id], conn) do
    IO.puts("GET /dog/#{dog_id}")
    page_contents = template_show_dog(dog_id)
    conn |> Plug.Conn.put_resp_content_type("text/html") |> Plug.Conn.send_resp(200, page_contents)
  end

  def route(method, path, conn) do
    IO.puts("#{String.upcase(method)} /#{path}")
    conn |> send_resp(404, "Not found.")
  end
  
end
