defmodule MerkleTree.Node do
  @moduledoc """
    This module implements a tree node abstraction.
  """

  defstruct [:value, :children, :height]

  @type t :: %MerkleTree.Node{
    value: String.t,
    children: [MerkleTree.Node.t],
    height: non_neg_integer
  }
end
