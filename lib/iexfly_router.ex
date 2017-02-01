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
  
  #get cookie
  #add custom header
  def route("GET", ["getcookie"], conn) do
    IO.puts("GET /getcookie")
    conn = Plug.Conn.fetch_cookies(conn)
    IO.inspect conn.cookies["test9"]
    IO.inspect conn.cookies["test91"]
    IO.inspect conn.cookies["test92"]
    
    conn = Plug.Conn.put_resp_header(conn, "x-header", "set")
    
    conn |> send_resp(200, "Hello, cookie!")
  end

  #getting path's parts to variables
  #set cookie
  def route("GET", ["hello", thing], conn) do
    IO.puts("GET /hello/#{thing}")
    
    conn = Plug.Conn.fetch_query_params(conn)
    
    conn = put_resp_cookie(conn, "test9", "тестова кука", max_age: 60*60*24*365)
    conn = put_resp_cookie(conn, "test91", "тестова кука2", max_age: 60*60*24*365, path: "/", http_only: false)
    #IO.inspect conn
    
    conn |> send_resp(200, "Hello, #{thing}!")
  end

  #getting get-params to variables
  # url/path?test1=777&test2=тест => %{"test1" => "777", "test2" => "тест"}
  # /cat/cat2?test1=777&test2=тест
  def route("GET", ["cat", cat_id], conn) do
    IO.puts("GET /cat/#{cat_id}")
    conn = Plug.Conn.fetch_query_params(conn)
    get_params = conn.query_params
    IO.inspect get_params["test1"]
    #"777"
    IO.inspect get_params["test3"]
    #nil
    conn = Plug.Conn.put_resp_content_type(conn, "text/html")
    conn |> send_resp(200, "You requested cat #{cat_id},<br>#{get_params["test1"]}<br>#{get_params["test2"]}")
  end

  #get post form
  #/postcat/cat2?test1=777&test2=тест
  EEx.function_from_file :defp, :template_getpost_cat, "lib/templates/getpost_cat.eex", [:cat_id]
  def route("GET", ["postcat", cat_id], conn) do
    IO.puts("GET /postcat/#{cat_id}")
    page_contents = template_getpost_cat(cat_id)
    conn |> Plug.Conn.put_resp_content_type("text/html") |> Plug.Conn.send_resp(200, page_contents)
  end

  #get&post params demo
  def route("POST", ["postcat", cat_id], conn) do
    IO.puts("POST /postcat/#{cat_id}")    
    conn = Plug.Conn.fetch_query_params(conn)
    get_params = conn.query_params
    #IO.inspect get_params["test1"]
    #"777"
    #IO.inspect get_params["test3"]
    #nil
    
    {:ok, post_params, conn} = Plug.Conn.read_body(conn, length: 1_000_000)
    post_params = URI.decode_query(post_params)
    
    conn |> Plug.Conn.put_resp_content_type("text/html") |> Plug.Conn.send_resp(200, "You requested postcat #{cat_id},<br>#{get_params["test1"]}<br>You sent post:<br>name: #{post_params["name"]}<br>old: #{post_params["old"]}")
  end

  #basic elixir template(s)
  def route("GET", ["user", user_id], conn) do
    IO.puts("GET /user/#{user_id}")
    page_contents = EEx.eval_file("lib/templates/show_user.eex", [user_id: user_id])
    conn |> Plug.Conn.put_resp_content_type("text/html") |> Plug.Conn.send_resp(200, page_contents)
  end

  #precompiling template(s)
  EEx.function_from_file :defp, :template_show_dog, "lib/templates/show_dog.eex", [:dog_id]
  def route("GET", ["dog", dog_id], conn) do
    IO.puts("GET /dog/#{dog_id}")
    page_contents = template_show_dog(dog_id)
    conn |> Plug.Conn.put_resp_content_type("text/html") |> Plug.Conn.send_resp(200, page_contents)
  end
  
  #template including template
  EEx.function_from_file :defp, :template_twice_1st, "lib/templates/twice_1st.eex", [:first_id, :second_id, :second_part]
  EEx.function_from_file :defp, :template_twice_2nd, "lib/templates/twice_2nd.eex", [:second_value]
  def route("GET", ["twice", second_id], conn) do
    IO.puts("GET /twice/#{second_id}")
    page_contents = template_twice_1st("test1", second_id, template_twice_2nd("test2 777"))
    conn |> Plug.Conn.put_resp_content_type("text/html") |> Plug.Conn.send_resp(200, page_contents)
  end

  def route(method, path, conn) do
    IO.puts("#{String.upcase(method)} /#{path}")
    #IO.inspect(method)
    #IO.inspect(path)
    #IO.inspect(conn)
    conn |> send_resp(404, "Not found.")
  end
  
end
