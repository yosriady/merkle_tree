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
    |> Enum.map(fn {x, proof} -> proven?(x, tree.root.value, tree.hash_function, proof) end)
    |> Enum.all?
  end

  # TODO: remove when deprecated MerkleTree.Proof.proven?/3 support ends
  test "correct proofs with deprecated proven?/3" do
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
    assert proven?({"f", 5}, tree.root.value, tree.hash_function, proof)

    # bad index
    assert not proven?({"f", 6}, tree.root.value, tree.hash_function, proof)

    incomplete_proof = %MerkleTree.Proof{
      hashes: tl(hashes),
      hash_function: tree.hash_function
    }
    assert not proven?({"f", 5}, tree.root.value, tree.hash_function, incomplete_proof)

    # different hash function
    assert not proven?({"f", 5}, tree.root.value, &(MerkleTree.Crypto.hash(&1, :sha224)), proof)

    corrupted_proof = %MerkleTree.Proof{
      hashes: [tree.hash_function.("z")] ++ tl(hashes),
      hash_function: tree.hash_function
    }
    assert not proven?({"f", 5}, tree.root.value, tree.hash_function, corrupted_proof)

    # corrupted root hash
    assert not proven?({"f", 5}, tree.hash_function.("z"), tree.hash_function, proof)

    # fake proof rejected with proven?/4
    fake_proof = %MerkleTree.Proof{
      hashes: Enum.map(hashes, fn _ -> "" end),
      hash_function: fn _ -> tree.root.value end
    }
    assert not proven?({"z", 5}, tree.root.value, tree.hash_function, fake_proof)
  end

  # TODO: remove when deprecated MerkleTree.Proof.proven?/3 support ends
  test "incorrect proof with deprecated proven?/3" do
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

    # fake proof accepted with deprecated proven?/3
    fake_proof = %MerkleTree.Proof{
      hashes: Enum.map(hashes, fn _ -> "" end),
      hash_function: fn _ -> tree.root.value end
    }
    assert proven?({"z", 5}, tree.root.value, fake_proof)
  end

end
