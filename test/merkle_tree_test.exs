defmodule MerkleTreeTest do
  use ExUnit.Case
  doctest MerkleTree

  @leaf_salt <<0>>
  @node_salt <<1>>

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
    f = MerkleTree.new(["a", "b", "c", "d"])
    assert f.root.value == "9dc1674ae1ee61c90ba50b6261e8f9a47f7ea07d92612158edfe3c2a37c6d74c"
  end

  test "ability to calculate tree in varying flavours of the builder functions equivalently" do
    assertions = fn blocks ->
      assert MerkleTree.build(blocks, height: 2).value == MerkleTree.fast_root(blocks, height: 2)
      assert MerkleTree.build(blocks).value == MerkleTree.fast_root(blocks)
      assert MerkleTree.new(blocks, height: 2, default_data_block: "").root == MerkleTree.build(blocks, height: 2)
      assert MerkleTree.new(blocks, default_data_block: "").root == MerkleTree.build(blocks)
    end

    [["a", "b", "c", "d"], ["a", "b", "c"], ["a", "b"], ["a"], []]
    |> Enum.map(assertions)
  end

  test "default data block with height" do
    assert MerkleTree.new(["a", "a", "a", "a"]) ==
             MerkleTree.new([], default_data_block: "a", height: 2)
  end

  test "default data block without height" do
    assert MerkleTree.new(List.duplicate("a", 8)) ==
             MerkleTree.new(List.duplicate("a", 5), default_data_block: "a")
  end

  test "default hash function sha256" do
    blocks = ["a", "a", "a", "a"]
    assert MerkleTree.new(blocks, &MerkleTree.Crypto.sha256/1) == MerkleTree.new(blocks)
  end

  test "merkle tree node" do
    hash = &MerkleTree.Crypto.sha256/1

    assert MerkleTree.build(["a", "b"], hash) == %MerkleTree.Node{
             children: [
               %MerkleTree.Node{
                 children: [],
                 height: 0,
                 value: hash.(@leaf_salt <> "a")
               },
               %MerkleTree.Node{
                 children: [],
                 height: 0,
                 value: hash.(@leaf_salt <> "b")
               }
             ],
             height: 1,
             value: hash.(@node_salt <> hash.(@leaf_salt <> "a") <> hash.(@leaf_salt <>"b"))
           }
  end
end
