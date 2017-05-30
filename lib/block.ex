defmodule GenChain.Block do
  @moduledoc """
  A GenChain Block
  """
  alias GenChain.Block

  @enforce_keys [:index, :previous_hash, :time_stamp, :block_data]
  defstruct [:index, :previous_hash, :time_stamp, :block_data, :block_hash]

  @type t(
    index,
    previous_hash,
    time_stamp,
    block_data,
    block_hash
  ) :: %Block{
    index: index,
    previous_hash: previous_hash,
    time_stamp: time_stamp,
    block_data: block_data,
    block_hash: block_hash
  }

  @type t :: %Block{
    index: integer,
    previous_hash: String.t,
    time_stamp: integer,
    block_data: String.t,
    block_hash: String.t
  }

  def initial_block do
    %Block{
      index: 0,
      previous_hash: "",
      time_stamp: 0,
      block_data: ""
    }
    |> attach_block_hash
  end

  def attach_block_hash(block) do
    %{ block | block_hash: hash(block) }
  end

  @doc """
  a new block is valid
  if its index is one higher than the previous block,
  if its previous hash matches the previous block hash,
  and if its hash was computed correctly
  """
  def is_valid_new_block?(
    %Block{} = prev,
    %Block{} = next
  ) do
    prev.index + 1 == next.index && prev.block_hash == next.previous_hash && next.block_hash == hash(next)
  end

  def is_valid_new_block?(tuple) when is_tuple(tuple) do
    is_valid_new_block?(
      elem(tuple, 0),
      elem(tuple, 1)
    )
  end

  def is_valid_chain(chain)
  when is_list(chain) do
    init = initial_block()
    case chain do
      [] -> true
      [^init] -> true
      [h | tail] ->
        block_pairs = Enum.zip(chain, tail)
        h == init
        && Enum.all?(block_pairs, &is_valid_new_block?/1)
      _ -> false
    end
  end

  @doc """
  given a previous block, mine the next one
  """
  def mine_new_block(
    %Block{} = previous_block,
    data
  ) when is_bitstring(data) do
    %Block{
      index: previous_block.index + 1,
      previous_hash: previous_block.block_hash,
      time_stamp: System.monotonic_time(),
      block_data: data
    }
    |> attach_block_hash
  end

  @spec to_string(Block) :: String.t
  def to_string(block) do
    "{"
    <> "index:#{block.index},"
    <> "previous_hash:#{block.previous_hash},"
    <> "time_stamp:#{block.time_stamp},"
    <> "block_data:#{block.block_data}"
    <> "}"
  end

  defp hash(block) do
    :crypto.hash(:sha256, strip_block_hash(block))
    |> Base.encode64
  end

  defp strip_block_hash(block) do
    block
    |> Map.take(@enforce_keys)
    |> Block.to_string
  end

end
