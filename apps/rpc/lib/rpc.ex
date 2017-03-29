defmodule Mercator.RPC do
  use Application

  defp chain_type, do: Application.get_env(:rpc, :chain_type)
  defp network, do: Application.get_env(:rpc, :network)

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Mercator.RPC.Worker.start_link(arg1, arg2, arg3)
      # worker(Mercator.RPC.Worker, [arg1, arg2, arg3]),
      worker(Application.get_env(:rpc, :rpc_lib),
             [%Gold.Config{
                 hostname: read_config!(:hostname),
                 port: read_config!(:port),
                 user: read_config!(:user),
                 password: read_config!(:password)},
              :rpc]),
      BitcoinTool.create_worker!(:pubkey_hex,
                                 %BitcoinTool.Config{
                                   input_type: "public-key",
                                   input_format: "hex",
                                   network: network
                                 }),
      worker(Mercator.RPC.Cache, [10000])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mercator.RPC.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def gettransaction!(txnid) do
    txnid
    |> Mercator.RPC.Cache.call(fn(id) ->
      :rpc
      |> Gold.getrawtransaction!(id)
      |> Base.decode16!(case: :lower)
      |> Bitcoin.Protocol.Types.Tx.parse(txnid, chain_type == :pos)
    end)
  end

  def gettransactions!(txnids) do
    txnids
    |> Mercator.RPC.Cache.call_batch(fn(ids) ->
      :rpc
      |> Gold.getrawtransactions!(ids)
      |> Enum.map(fn {txnid, rawtxn} ->
        txn = rawtxn
        |> Base.decode16!(case: :lower)
        |> Bitcoin.Protocol.Types.Tx.parse(txnid, chain_type == :pos)
        {txnid, txn}
      end)
    end)
  end

  defp read_config!(param) do
    case Application.get_env(:rpc, param) do
      {:system, var} -> System.get_env(var)
      var -> var
    end
  end
end
