defmodule Mercator.Web.Router do
  use Mercator.Web.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Mercator.Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api/v1/block", Mercator.Web do
    pipe_through :api

    get "/info/:height", BlockController, :info
  end

  scope "/api/v1/tx", Mercator.Web do
    pipe_through :api

    post "/push", TxController, :push
  end

  # Other scopes may use custom stacks.
  # scope "/api", Mercator.Web do
  #   pipe_through :api
  # end
end
