defmodule PijiWeb.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/:id" do
    with {id, ""} <- Integer.parse(conn.params["id"]),
         value when not is_nil(value) <- Piji.Cache.get(id),
         {:ok, value} = Jason.encode(value) do
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, value)
    else
      nil -> send_resp(conn, 404, "Not found")
      _ -> send_resp(conn, 400, "Bad Request")
    end
  end
end
