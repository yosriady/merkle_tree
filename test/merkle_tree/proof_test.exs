defmodule MerkleTree.ProofTest do
  use ExUnit.Case
  doctest MerkleTree.Proof

  import MerkleTree.Proof

  test "correct proofs" do
    blocks = ~w/a b c d e f g h/
    tree = MerkleTree.new blocks

    proofs = blocks
    |> Enum.with_index
    |> Enum.map(fn {_, idx} -> prove(tree, idx) end)

    assert blocks
    |> Enum.with_index
    |> Enum.zip(proofs)
    |> Enum.map(fn {x, proof} -> proven?(x, tree.root.value, proof) end)
    |> Enum.all?
  end

  test "incorrect proof" do
    blocks = ~w/a b c d e f g h/
    tree = MerkleTree.new blocks
    %MerkleTree.Proof{hashes: hashes} = proof = prove(tree, 5)

    # test sanity
    assert proven?({"f", 5}, tree.root.value, proof)

    # bad index
    assert not proven?({"f", 6}, tree.root.value, proof)

    incomplete_proof = %MerkleTree.Proof{
      hashes: tl(hashes),
      hash_function: tree.hash_function
    }
    assert not proven?({"f", 5}, tree.root.value, incomplete_proof)

    different_hash = %MerkleTree.Proof{
      hashes: hashes,
      hash_function: &(MerkleTree.Crypto.hash(&1, :sha224))
    }
    assert not proven?({"f", 5}, tree.root.value, different_hash)

    corrupted_proof = %MerkleTree.Proof{
      hashes: [tree.hash_function.("z")] ++ tl(hashes),
      hash_function: tree.hash_function
    }
    assert not proven?({"f", 5}, tree.root.value, corrupted_proof)

    # corrupted root hash
    assert not proven?({"f", 5}, tree.hash_function.("z"), proof)
  end

end
