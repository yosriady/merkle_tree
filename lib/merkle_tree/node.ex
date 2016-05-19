defmodule MerkleTree.Node do
  defstruct [:value, :children]

  @type t :: %MerkleTree.Node{
    value: String.t,
    children: [MerkleTree.Node.t],
  }
end
