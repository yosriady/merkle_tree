defmodule MerkleTree do
  @moduledoc """
    A hash tree or Merkle tree is a tree in which every non-leaf node is labelled
    with the hash of the labels or values (in case of leaves) of its child nodes.
    Hash trees are useful because they allow efficient and secure verification of
    the contents of large data structures.

      ## Usage Example

      iex> MerkleTree.new ['a', 'b', 'c', 'd']
      %MerkleTree{blocks: ['a', 'b', 'c', 'd'], hash_function: &MerkleTree.Crypto.sha256/1,
            root: %MerkleTree.Node{children: [%MerkleTree.Node{children: [%MerkleTree.Node{children: [], height: 0,
                 value: "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"},
                %MerkleTree.Node{children: [], height: 0, value: "3e23e8160039594a33894f6564e1b1348bbd7a0088d42c4acb73eeaed59c009d"}], height: 1,
               value: "62af5c3cb8da3e4f25061e829ebeea5c7513c54949115b1acc225930a90154da"},
              %MerkleTree.Node{children: [%MerkleTree.Node{children: [], height: 0,
                 value: "2e7d2c03a9507ae265ecf5b5356885a53393a2029d241394997265a1a25aefc6"},
                %MerkleTree.Node{children: [], height: 0, value: "18ac3e7343f016890c510e93f935261169d9e3f565436429830faf0934f4f8e4"}], height: 1,
               value: "d3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891a"}], height: 2,
             value: "58c89d709329eb37285837b042ab6ff72c7c8f74de0446b091b6a0131c102cfd"}}
  """

  defstruct [:blocks, :root, :hash_function]

  # Number of children per node. Configurable.
  @number_of_children 2

  @type blocks :: [String.t(), ...]
  @type hash_function :: (String.t() -> String.t())
  @type root :: MerkleTree.Node.t()
  @type t :: %MerkleTree{
          blocks: blocks,
          root: root,
          hash_function: hash_function
        }

  @doc """
    Creates a new merkle tree, given a blocks and hash function or opts
     available options:
      :hash_function - used hash in mercle tree default :sha256 from :cryto
      :hash_leaves - flag says whether the leaves should be hashed, default true
      :height - allows to construct tree of provided height,
          empty leaves data will be taken from `:default_data_block` parameter
      :default_data_block - this data will be used to supply empty
          leaves in case where there isn't enough blocks provided
  Check out `MerkleTree.Crypto` for other available cryptographic hashes.
  Alternatively, you can supply your own hash function that has the spec
  ``(String.t -> String.t)``.
  """
  @spec new(blocks, hash_function | list({atom, any})) :: t

  def new(blocks, hash_function) when is_function(hash_function),
    do: new(blocks, hash_function: hash_function)

  def new(blocks, opts \\ []) when is_list(opts) do
    hash_function = Keyword.get(opts, :hash_function, &MerkleTree.Crypto.sha256/1)

    blocks = fill_blocks(blocks, Keyword.get(opts, :default_data_block), Keyword.get(opts, :height))

    leaves =
      if Keyword.get(opts, :hash_leaves, true),
        do: Enum.map(blocks, hash_function),
        else: blocks

    nodes =
      Enum.map(leaves, fn block ->
        %MerkleTree.Node{
          value: block,
          children: [],
          height: 0
        }
      end)

    root = _build(nodes, hash_function, 0)
    %MerkleTree{blocks: blocks, hash_function: hash_function, root: root}
  end

  @doc """
    Builds a new binary merkle tree.
  """
  @spec build(blocks, hash_function) :: root
  def build(blocks, hash_function) do
    starting_height = 0

    leaves =
      Enum.map(blocks, fn block ->
        %MerkleTree.Node{
          value: hash_function.(block),
          children: [],
          height: starting_height
        }
      end)

    _build(leaves, hash_function, starting_height)
  end

  # Base case
  defp _build([root], _, _), do: root
  # Recursive case
  defp _build(nodes, hash_function, previous_height) do
    children_partitions = Enum.chunk(nodes, @number_of_children)
    height = previous_height + 1

    parents =
      Enum.map(children_partitions, fn partition ->
        concatenated_values =
          partition
          |> Enum.map(& &1.value)
          |> Enum.reduce("", fn x, acc -> acc <> x end)

        %MerkleTree.Node{
          value: hash_function.(concatenated_values),
          children: partition,
          height: height
        }
      end)

    _build(parents, hash_function, height)
  end

  defp _ceil(a), do: if(a > trunc(a), do: trunc(a) + 1, else: trunc(a))

  defp fill_blocks(blocks, default, nil) when default != nil do
    blocks_count = Enum.count(blocks)
    leaves_count = :math.pow(2, _ceil(:math.log2(blocks_count)))
    blocks ++ List.duplicate(default, trunc(leaves_count - blocks_count))
  end

  defp fill_blocks(blocks, default, height) when default != nil do
    blocks_count = Enum.count(blocks)
    leaves_count = :math.pow(2, height)
    fill_elements = leaves_count - blocks_count
    if fill_elements < 0, do: raise(MerkleTree.ArgumentError)
    blocks ++ List.duplicate(default, trunc(fill_elements))
  end

  defp fill_blocks(blocks, _, _) when blocks != [] do
    amout_elements = Enum.count(blocks)
    required_leaves_count = :math.pow(2, _ceil(:math.log2(amout_elements)))

    if required_leaves_count != amout_elements,
      do: raise(MerkleTree.ArgumentError),
      else: blocks
  end
end
