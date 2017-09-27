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

  test "correct proofs" do
    blocks = ~w/a b c d e f g h/
    tree = MerkleTree.new blocks

    proofs = blocks
    |> Enum.with_index
    |> Enum.map(fn {_, idx} -> MerkleTree.prove(tree, idx) end)

    assert blocks
    |> Enum.with_index
    |> Enum.zip(proofs)
    |> Enum.map(fn {x, proof} -> MerkleTree.proven?(x, tree.root.value, proof) end)
    |> Enum.all?
  end

  test "incorrect proof" do
    blocks = ~w/a b c d e f g h/
    tree = MerkleTree.new blocks
    {hashes, _} = proof = MerkleTree.prove(tree, 5)

    # test sanity
    assert MerkleTree.proven?({"f", 5}, tree.root.value, proof)

    # bad index
    assert not MerkleTree.proven?({"f", 6}, tree.root.value, proof)

    incomplete_proof = {tl(hashes), tree.hash_function}
    assert not MerkleTree.proven?({"f", 5}, tree.root.value, incomplete_proof)

    # different hash
    different_hash = {hashes, &(MerkleTree.Crypto.hash(&1, :sha224))}
    assert not MerkleTree.proven?({"f", 5}, tree.root.value, different_hash)

    corrupted_proof = {[tree.hash_function.("z")] ++ tl(hashes), tree.hash_function}
    assert not MerkleTree.proven?({"f", 5}, tree.root.value, corrupted_proof)

    # corrupted root hash
    assert not MerkleTree.proven?({"f", 5}, tree.hash_function.("z"), proof)
  end
end
