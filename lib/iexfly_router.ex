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
  import Iexfly.Gettext, only: [gettext: 1, gettext: 2]
  import Gettext, only: [put_locale: 2]
  #alias Iexfly.Template, as: T
  import Iexfly.Template
  
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
  def route("GET", ["dog", dog_id], conn) do
    IO.puts("GET /dog/#{dog_id}")
    page_contents = template_show_dog(dog_id)
    conn |> Plug.Conn.put_resp_content_type("text/html") |> Plug.Conn.send_resp(200, page_contents)
  end

  #template including template
  def route("GET", ["twice", second_id], conn) do
    IO.puts("GET /twice/#{second_id}")
    page_contents = template_twice_1st("test1", second_id, template_twice_2nd("test2 777"))
    conn |> Plug.Conn.put_resp_content_type("text/html") |> Plug.Conn.send_resp(200, page_contents)
  end

  #dtl template including template (erlydtl)
  def route("GET", ["dtl"], conn) do
    IO.puts("GET /dtl")
    
    {:ok, name2} = :dtl_2nd.render([{:name0, "J.В."}])
    {:ok, page_contents0} = :dtl_1st.render([
      {:name, 'Johnny Василіч'},
      {:friends, ["Frankie Lee", "Judas Priest"]},
      {:primes, [1, 2, '3', "5", <<"777">>]},
      {:name2, Enum.join(name2)}
    ])
    page_contents = Enum.join(page_contents0)
    conn |> Plug.Conn.put_resp_content_type("text/html") |> Plug.Conn.send_resp(200, page_contents)
  end

  #vk api request demo (request api, json)
  def route("GET", ["vkapi"], conn) do
    IO.puts("GET /vkapi")
    
    #better add ssl & inets to mix applications list
    :ssl.start()
    :inets.start()
    #{:ok,{status,headers,content}} = :httpc.request 'http://httpbin.org/ip'
    {:ok,{_,_,content}} = :httpc.request(:get, {'https://api.vk.com/method/users.get?user_ids=1&fields=photo_big&name_case=Nom&version=5.30', 
    [{'User-Agent', 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101 Firefox/45.0'}, {'Accept-language', 'ru,ru_RU\r\n'}, {'Cookie', 'remixlang=0\r\n'}]}, [], [])
    :ssl.stop()
    :inets.stop()
    
    data = Jazz.decode!(Kernel.to_string(content))
    #IO.inspect data
    #IO.inspect data["response"]
    [page_contents|_] = data["response"]
    #IO.inspect page_contents
    #IO.inspect page_contents["first_name"]
    #IO.inspect :io.format("~s~n",[page_contents["first_name"]])
    
    name1 = :unicode.characters_to_binary(:unicode.characters_to_list(page_contents["first_name"]), :utf8, :latin1)
    name2 = :unicode.characters_to_binary(:unicode.characters_to_list(page_contents["last_name"]), :utf8, :latin1)
    
    page_contents = Integer.to_string(page_contents["uid"]) <> ": " <> name1 <> " " <> name2 <> "<br><img src=\""<> page_contents["photo_big"] <> "\"><br>"
    
    conn |> Plug.Conn.put_resp_content_type("text/html") |> send_resp(200, page_contents)
  end

  #gettext i18n test
  def route("GET", ["gettext", lang], conn) do
    IO.puts("GET /gettext/#{lang}")
    
    lang = case lang do
      "en" -> "en"
      "ru" -> "ru"
      "ua" -> "ua"
      _ -> "en"
    end
    put_locale(Iexfly.Gettext, lang)
    
    #gettext "Hello!"
    #gettext("Hello!")
    #gettext "Welcome to %{name}", name: "this demo!"
    #{:safe, gettext "Welcome<br> to %{name}", name: "this demo!"}
    hello_text = gettext "happy using gettext for you, my friend!"
    
    conn = Plug.Conn.put_resp_content_type(conn, "text/html")
    conn |> send_resp(200, "You requested gettext demo<br>lang: #{lang},<br>#{hello_text}")
  end

  def route(method, path, conn) do
    IO.puts("#{String.upcase(method)} /#{path}")
    #IO.inspect(method)
    #IO.inspect(path)
    #IO.inspect(conn)
    conn |> send_resp(404, "Not found.")
  end
  
end
