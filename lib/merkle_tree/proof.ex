defmodule MerkleTree.Proof do
  @moduledoc """
    Generate and verify merkle proofs

      ## Usage Example
      iex> proof = MerkleTree.new(~w/a b c d/) |>
      ...> MerkleTree.Proof.prove(1)
      ["40e2511a6323177e537acb2e90886e0da1f84656fd6334b89f60d742a3967f09",
        "022a6979e6dab7aa5ae4c3e5e45f7e977112a7e63593820dbec1ec738a24f93c"]
      iex> MerkleTree.Proof.proven?({"b", 1}, "9dc1674ae1ee61c90ba50b6261e8f9a47f7ea07d92612158edfe3c2a37c6d74c", &MerkleTree.Crypto.sha256/1, proof)
      true

  """
  @leaf_salt <<0>>
  @node_salt <<1>>

  defstruct [:hashes, :hash_function]

  @type proof_t() :: list(String.t())

  @doc """
  Generates proof for a block at a specific index
  """
  @spec prove(MerkleTree.t() | MerkleTree.Node.t(), non_neg_integer) :: proof_t()
  def prove(%MerkleTree{root: root}, index),
    do: prove(root, index)

  def prove(%MerkleTree.Node{height: height} = root, index),
    do: _prove(root, binarize(index, height))

  defp _prove(_, ""), do: []

  defp _prove(
         %MerkleTree.Node{children: children},
         index_binary
       ) do
    {path_head, path_tail} = path_from_binary(index_binary)

    [child, sibling] =
      case path_head do
        1 -> Enum.reverse(children)
        0 -> children
      end

    [sibling.value] ++ _prove(child, path_tail)
  end

  @doc """
  Verifies proof for a block at a specific index
  """
  @spec proven?({String.t(), non_neg_integer}, String.t(), MerkleTree.hash_function(), proof_t()) :: boolean
  def proven?({block, index}, root_hash, hash_function, proof) do
    height = length(proof)
    root_hash == _hash_proof(block, binarize(index, height), proof, hash_function)
  end

  defp _hash_proof(block, "", [], hash_function) do
    hash_function.(@leaf_salt <> block)
  end

  defp _hash_proof(block, index_binary, [proof_head | proof_tail], hash_function) do
    {path_head, path_tail} = path_from_binary(index_binary)

    case path_head do
      1 -> hash_function.(@node_salt <> proof_head <> _hash_proof(block, path_tail, proof_tail, hash_function))
      0 -> hash_function.(@node_salt <> _hash_proof(block, path_tail, proof_tail, hash_function) <> proof_head)
    end
  end

  @spec binarize(integer, integer) :: bitstring
  defp binarize(index, height) do
    <<index_binary::binary-unit(1)>> = <<index::unsigned-big-integer-size(height)>>
    index_binary
  end

  @spec path_from_binary(bitstring) :: {0 | 1, bitstring}
  defp path_from_binary(index_binary) do
    <<path_head::unsigned-big-integer-unit(1)-size(1), path_tail::binary-unit(1)>> = index_binary
    {path_head, path_tail}
  end
end
