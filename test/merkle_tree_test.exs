defmodule MerkleTreeTest do
  use ExUnit.Case
  doctest MerkleTree

  test "invalid empty blocks" do
    assert_raise(FunctionClauseError, (fn() -> MerkleTree.new [] end))
  end

  test "invalid block size" do
    assert_raise(MerkleTree.ArgumentError, (fn() -> MerkleTree.new ["a", "b", "c"] end))
  end

  test "primary use case" do
    f = MerkleTree.new ['a', 'b', 'c', 'd']
    assert f.root.value == "58c89d709329eb37285837b042ab6ff72c7c8f74de0446b091b6a0131c102cfd"
  end
end
