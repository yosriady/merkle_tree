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
    Creates a new merkle tree, given a blocks and hash function or opts.
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
  @spec new(blocks, hash_function | Keyword.t()) :: t
  def new(blocks, hash_function_or_opts \\ [])

  def new(blocks, hash_function) when is_function(hash_function),
    do: new(blocks, hash_function: hash_function)

  def new(blocks, opts) when is_list(opts) do
    # fill in the data blocks, note we don't allow to fill in with in with a sensible default here, like ""
    filled_blocks = fill_blocks(blocks, Keyword.get(opts, :default_data_block), Keyword.get(opts, :height))
    # calculate the root node, which does all the hashing etc.
    root = build(blocks, opts)

    hash_function = Keyword.get(opts, :hash_function, &MerkleTree.Crypto.sha256/1)
    %MerkleTree{blocks: filled_blocks, hash_function: hash_function, root: root}
  end

  @doc """
  Calculates the root of the merkle tree without building the entire tree explicitly,

  See `new/2` for a rundown of options
  """
  @spec fast_root(blocks, Keyword.t()) :: MerkleTree.Node.hash()
  def fast_root(blocks, opts \\ []) do
    {hash_function, height, hash_leaves?, default_data_block} = get_from_options(opts, blocks)

    default_leaf_value = if hash_leaves?, do: hash_function.(default_data_block), else: default_data_block
    leaf_values = if hash_leaves?, do: Enum.map(blocks, hash_function), else: blocks

    _fast_root(leaf_values, hash_function, 0, default_leaf_value, height)
  end

  defp _fast_root([], hash_function, height, default_leaf, final_height),
    do: _fast_root([default_leaf], hash_function, height, default_leaf, final_height)

  defp _fast_root([root], _, final_height, _, final_height), do: root

  defp _fast_root(nodes, hash_function, height, default_leaf, final_height) do
    count = step = @number_of_children
    leftover = List.duplicate(default_leaf, count - 1)
    children_partitions = Enum.chunk_every(nodes, count, step, leftover)
    new_height = height + 1

    parents =
      Enum.map(children_partitions, fn partition ->
        concatenated_values = partition |> Enum.join()
        hash_function.(concatenated_values)
      end)

    new_default_leaf_value = hash_function.(default_leaf <> default_leaf)

    _fast_root(parents, hash_function, new_height, new_default_leaf_value, final_height)
  end

  # takes care of the defaults etc
  defp get_from_options(opts, blocks) do
    {
      Keyword.get(opts, :hash_function, &MerkleTree.Crypto.sha256/1),
      Keyword.get(opts, :height, guess_height(Enum.count(blocks))),
      Keyword.get(opts, :hash_leaves, true),
      Keyword.get(opts, :default_data_block, "")
    }
  end

  @doc """
  Builds a root MerkleTree.Node structure of a merkle tree

  See `new/2` for a rundown of options
  """
  @spec build(blocks, hash_function | Keyword.t()) :: root
  def build(blocks, hash_function_or_opts \\ [])

  def build(blocks, hash_function) when is_function(hash_function),
    do: build(blocks, hash_function: hash_function)

  def build(blocks, opts) do
    {hash_function, height, hash_leaves?, default_data_block} = get_from_options(opts, blocks)

    default_leaf_value = if hash_leaves?, do: hash_function.(default_data_block), else: default_data_block
    leaf_values = if hash_leaves?, do: Enum.map(blocks, hash_function), else: blocks
    default_leaf = %MerkleTree.Node{value: default_leaf_value, children: [], height: 0}
    leaves = Enum.map(leaf_values, &%MerkleTree.Node{value: &1, children: [], height: 0})

    _build(leaves, hash_function, 0, default_leaf, height)
  end

  defp _build([], hash_function, height, default_leaf, final_height),
    do: _build([default_leaf], hash_function, height, default_leaf, final_height)

  # Base case
  defp _build([root], _, final_height, _, final_height), do: root
  # Recursive case
  defp _build(nodes, hash_function, height, default_leaf, final_height) do
    count = step = @number_of_children
    leftover = List.duplicate(default_leaf, count - 1)
    children_partitions = Enum.chunk_every(nodes, count, step, leftover)
    new_height = height + 1

    parents =
      Enum.map(children_partitions, fn partition ->
        concatenated_values = partition |> Enum.map(& &1.value) |> Enum.join()

        %MerkleTree.Node{
          value: hash_function.(concatenated_values),
          children: partition,
          height: new_height
        }
      end)

    new_default_leaf_value = hash_function.(default_leaf.value <> default_leaf.value)

    new_default_leaf = %MerkleTree.Node{
      value: new_default_leaf_value,
      children: List.duplicate(default_leaf, @number_of_children),
      height: new_height
    }

    _build(parents, hash_function, new_height, new_default_leaf, final_height)
  end

  defp _ceil(a), do: if(a > trunc(a), do: trunc(a) + 1, else: trunc(a))

  defp fill_blocks(blocks, default, nil) when default != nil do
    blocks_count = Enum.count(blocks)
    leaves_count = guess_leaves_count(blocks_count)
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

  defp guess_leaves_count(blocks_count), do: :math.pow(2, guess_height(blocks_count))
  defp guess_height(0), do: 0
  defp guess_height(blocks_count), do: _ceil(:math.log2(blocks_count))
end
