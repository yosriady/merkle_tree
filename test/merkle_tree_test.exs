defmodule MerkleTreeTest do
  use ExUnit.Case
  doctest MerkleTree

  test "invalid empty blocks" do
    assert_raise(FunctionClauseError, fn -> MerkleTree.new([]) end)
  end

  test "valid empty blocks when default given" do
    assert %MerkleTree{} = MerkleTree.new([], default_data_block: "")
  end

  test "invalid block size and no default data" do
    assert_raise(MerkleTree.ArgumentError, fn -> MerkleTree.new(["a", "b", "c"]) end)
  end

  test "primary use case" do
    f = MerkleTree.new(['a', 'b', 'c', 'd'])
    assert f.root.value == "58c89d709329eb37285837b042ab6ff72c7c8f74de0446b091b6a0131c102cfd"
  end

  test "ability to calculate tree in varying flavours of the builder functions equivalently" do
    assertions = fn blocks ->
      assert MerkleTree.build(blocks, height: 2).value == MerkleTree.fast_root(blocks, height: 2)
      assert MerkleTree.build(blocks).value == MerkleTree.fast_root(blocks)
      assert MerkleTree.new(blocks, height: 2, default_data_block: "").root == MerkleTree.build(blocks, height: 2)
      assert MerkleTree.new(blocks, default_data_block: "").root == MerkleTree.build(blocks)
    end

    [['a', 'b', 'c', 'd'], ['a', 'b', 'c'], ['a', 'b'], ['a'], []]
    |> Enum.map(assertions)
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
             MerkleTree.new(blocks |> Enum.map(&MerkleTree.Crypto.sha256/1), hash_leaves: false).root
  end

  test "default hash function sha256" do
    blocks = ['a', 'a', 'a', 'a']
    assert MerkleTree.new(blocks, &MerkleTree.Crypto.sha256/1) == MerkleTree.new(blocks)
  end

  test "merkle tree node" do
    hash = &MerkleTree.Crypto.sha256/1

    assert MerkleTree.build(['a', 'b'], &MerkleTree.Crypto.sha256/1) == %MerkleTree.Node{
             children: [
               %MerkleTree.Node{
                 children: [],
                 height: 0,
                 value: hash.('a')
               },
               %MerkleTree.Node{
                 children: [],
                 height: 0,
                 value: hash.('b')
               }
             ],
             height: 1,
             value: hash.(hash.('a') <> hash.('b'))
           }
  end
end
