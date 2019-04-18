defmodule MerkleTree.Proof do
  @moduledoc """
    Generate and verify merkle proofs

      ## Usage Example
      iex> proof = MerkleTree.new(~w/a b c d/) |>
      ...> MerkleTree.Proof.prove(1)
      %MerkleTree.Proof{hash_function: &MerkleTree.Crypto.sha256/1,
       hashes: ["d3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891a",
        "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"]}
      iex> MerkleTree.Proof.proven?({"b", 1}, "58c89d709329eb37285837b042ab6ff72c7c8f74de0446b091b6a0131c102cfd", proof)
      true

  """
  defstruct [:hashes, :hash_function]

  @type t :: %MerkleTree.Proof{
          hashes: [String.t(), ...],
          # TODO: remove when deprecated MerkleTree.Proof.proven?/3 support ends
          hash_function: MerkleTree.hash_function() | nil
        }

  @doc """
  Generates proof for a block at a specific index
  """
  @spec prove(MerkleTree.t() | MerkleTree.Node.t(), non_neg_integer) :: t
  def prove(%MerkleTree{root: root} = tree, index),
    # TODO: remove the struct update with hash function, when deprecated MerkleTree.Proof.proven?/3 support ends
    do: %MerkleTree.Proof{prove(root, index) | hash_function: tree.hash_function}

  def prove(%MerkleTree.Node{height: height} = root, index),
    do: %MerkleTree.Proof{hashes: _prove(root, binarize(index, height))}

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
  @spec proven?({String.t(), non_neg_integer}, String.t(), MerkleTree.hash_function(), t) :: boolean
  def proven?({block, index}, root_hash, hash_function, %MerkleTree.Proof{hashes: proof}) do
    height = length(proof)
    root_hash == _hash_proof(block, binarize(index, height), proof, hash_function)
  end

  @doc false
  @deprecated "Use proven?/4 instead"
  # TODO: remove when deprecated MerkleTree.Proof.proven?/3 support ends
  def proven?({block, index}, root_hash, %MerkleTree.Proof{hashes: proof, hash_function: hash_function}) do
    height = length(proof)
    root_hash == _hash_proof(block, binarize(index, height), proof, hash_function)
  end

  defp _hash_proof(block, "", [], hash_function) do
    hash_function.(block)
  end

  defp _hash_proof(block, index_binary, [proof_head | proof_tail], hash_function) do
    {path_head, path_tail} = path_from_binary(index_binary)

    case path_head do
      1 -> hash_function.(proof_head <> _hash_proof(block, path_tail, proof_tail, hash_function))
      0 -> hash_function.(_hash_proof(block, path_tail, proof_tail, hash_function) <> proof_head)
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
