defmodule MerkleTree.Node do
  @moduledoc """
    This module implements a tree node abstraction.
  """

  defstruct [:value, :children]

  @type t :: %MerkleTree.Node{
    value: String.t,
    children: [MerkleTree.Node.t],
  }
end
