defmodule MerkleTree.ArgumentError do
  defexception message: "MerkleTree.new requires a power of 2 (2^N) number of blocks."
end
