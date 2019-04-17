defmodule MerkleTree.Crypto do
  @moduledoc """
    This module defines some cryptographic hash functions used to hash block
    contents.
  """

  @type algorithm :: :md5 | :sha | :sha224 | :sha256 | :sha384 | :sha512

  @spec sha256(String.t()) :: String.t()
  def sha256(data) do
    hash(data, :sha256)
  end

  @spec hash(String.t(), algorithm) :: String.t()
  def hash(data, algorithm) do
    :crypto.hash(algorithm, data) |> Base.encode16(case: :lower)
  end
end
