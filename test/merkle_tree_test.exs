defmodule MerkleTreeTest do
  use ExUnit.Case
  doctest MerkleTree

  test "invalid block size" do
    f = MerkleTree.new ['a', 'b', 'c']
  end
end
