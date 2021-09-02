defmodule PijiWeb.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/:id" do
    conn.params["id"]
    |> Piji.Cache.get()
    |> case do
      nil ->
        send_resp(conn, 404, "Not found")

      value ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(200, Jason.encode!(value))
    end
  end
end
