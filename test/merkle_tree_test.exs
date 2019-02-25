defmodule MerkleTreeTest do
  use ExUnit.Case
  doctest MerkleTree

  test "invalid empty blocks" do
    assert_raise(FunctionClauseError, fn -> MerkleTree.new([]) end)
  end

  test "invalid block size" do
    assert_raise(MerkleTree.ArgumentError, fn -> MerkleTree.new(["a", "b", "c"]) end)
  end

  test "primary use case" do
    f = MerkleTree.new(['a', 'b', 'c', 'd'])
    assert f.root.value == "58c89d709329eb37285837b042ab6ff72c7c8f74de0446b091b6a0131c102cfd"
  end

  test "default data block with height" do
    assert MerkleTree.new(['a', 'a', 'a', 'a']) ==
             MerkleTree.new([], default_data_block: 'a', height: 2)
  end

  test "default data block without height" do
    assert MerkleTree.new(List.duplicate('a', 8)) ==
             MerkleTree.new(List.duplicate('a', 5), default_data_block: 'a')
  end

  test "check hash leaf false" do
    blocks = ['a', 'a', 'a', 'a']

    assert MerkleTree.new(blocks).root ==
             MerkleTree.new(blocks |> Enum.map(&MerkleTree.Crypto.sha256/1), hash_leaf: false).root
  end
end
