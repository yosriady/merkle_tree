searchNodes=[{"ref":"MerkleTree.html","title":"MerkleTree","type":"module","doc":"A hash tree or Merkle tree is a tree in which every non-leaf node is labelled with the hash of the labels or values (in case of leaves) of its child nodes. Hash trees are useful because they allow efficient and secure verification of the contents of large data structures. ## Usage Example iex&gt; MerkleTree.new [&quot;a&quot;, &quot;b&quot;, &quot;c&quot;, &quot;d&quot;] %MerkleTree{ blocks: [&quot;a&quot;, &quot;b&quot;, &quot;c&quot;, &quot;d&quot;], hash_function: &amp;MerkleTree.Crypto.sha256/1, root: %MerkleTree.Node{ children: [ %MerkleTree.Node{ children: [ %MerkleTree.Node{ children: [], height: 0, value: &quot;022a6979e6dab7aa5ae4c3e5e45f7e977112a7e63593820dbec1ec738a24f93c&quot; }, %MerkleTree.Node{ children: [], height: 0, value: &quot;57eb35615d47f34ec714cacdf5fd74608a5e8e102724e80b24b287c0c27b6a31&quot; } ], height: 1, value: &quot;4c64254e6636add7f281ff49278beceb26378bd0021d1809974994e6e233ec35&quot; }, %MerkleTree.Node{ children: [ %MerkleTree.Node{ children: [], height: 0, value: &quot;597fcb31282d34654c200d3418fca5705c648ebf326ec73d8ddef11841f876d8&quot; }, %MerkleTree.Node{ children: [], height: 0, value: &quot;d070dc5b8da9aea7dc0f5ad4c29d89965200059c9a0ceca3abd5da2492dcb71d&quot; } ], height: 1, value: &quot;40e2511a6323177e537acb2e90886e0da1f84656fd6334b89f60d742a3967f09&quot; } ], height: 2, value: &quot;9dc1674ae1ee61c90ba50b6261e8f9a47f7ea07d92612158edfe3c2a37c6d74c&quot; } }"},{"ref":"MerkleTree.html#build/2","title":"MerkleTree.build/2","type":"function","doc":"Builds a root MerkleTree.Node structure of a merkle tree See new/2 for a rundown of options"},{"ref":"MerkleTree.html#fast_root/2","title":"MerkleTree.fast_root/2","type":"function","doc":"Calculates the root of the merkle tree without building the entire tree explicitly, See new/2 for a rundown of options"},{"ref":"MerkleTree.html#new/2","title":"MerkleTree.new/2","type":"function","doc":"Creates a new merkle tree, given a blocks and hash function or opts. available options: :hash_function - used hash in mercle tree default :sha256 from :cryto :height - allows to construct tree of provided height, empty leaves data will be taken from `:default_data_block` parameter :default_data_block - this data will be used to supply empty leaves in case where there isn&#39;t enough blocks provided Check out MerkleTree.Crypto for other available cryptographic hashes. Alternatively, you can supply your own hash function that has the spec (String.t -&gt; String.t)."},{"ref":"MerkleTree.html#t:blocks/0","title":"MerkleTree.blocks/0","type":"type","doc":""},{"ref":"MerkleTree.html#t:hash_function/0","title":"MerkleTree.hash_function/0","type":"type","doc":""},{"ref":"MerkleTree.html#t:root/0","title":"MerkleTree.root/0","type":"type","doc":""},{"ref":"MerkleTree.html#t:t/0","title":"MerkleTree.t/0","type":"type","doc":""},{"ref":"MerkleTree.ArgumentError.html","title":"MerkleTree.ArgumentError","type":"exception","doc":""},{"ref":"MerkleTree.Crypto.html","title":"MerkleTree.Crypto","type":"module","doc":"This module defines some cryptographic hash functions used to hash block contents."},{"ref":"MerkleTree.Crypto.html#hash/2","title":"MerkleTree.Crypto.hash/2","type":"function","doc":""},{"ref":"MerkleTree.Crypto.html#sha256/1","title":"MerkleTree.Crypto.sha256/1","type":"function","doc":""},{"ref":"MerkleTree.Crypto.html#t:algorithm/0","title":"MerkleTree.Crypto.algorithm/0","type":"type","doc":""},{"ref":"MerkleTree.Node.html","title":"MerkleTree.Node","type":"module","doc":"This module implements a tree node abstraction."},{"ref":"MerkleTree.Node.html#t:hash/0","title":"MerkleTree.Node.hash/0","type":"type","doc":""},{"ref":"MerkleTree.Node.html#t:t/0","title":"MerkleTree.Node.t/0","type":"type","doc":""},{"ref":"MerkleTree.Proof.html","title":"MerkleTree.Proof","type":"module","doc":"Generate and verify merkle proofs ## Usage Example iex&gt; proof = MerkleTree.new(~w/a b c d/) |&gt; ...&gt; MerkleTree.Proof.prove(1) [&quot;40e2511a6323177e537acb2e90886e0da1f84656fd6334b89f60d742a3967f09&quot;, &quot;022a6979e6dab7aa5ae4c3e5e45f7e977112a7e63593820dbec1ec738a24f93c&quot;] iex&gt; MerkleTree.Proof.proven?({&quot;b&quot;, 1}, &quot;9dc1674ae1ee61c90ba50b6261e8f9a47f7ea07d92612158edfe3c2a37c6d74c&quot;, &amp;MerkleTree.Crypto.sha256/1, proof) true"},{"ref":"MerkleTree.Proof.html#prove/2","title":"MerkleTree.Proof.prove/2","type":"function","doc":"Generates proof for a block at a specific index"},{"ref":"MerkleTree.Proof.html#proven?/4","title":"MerkleTree.Proof.proven?/4","type":"function","doc":"Verifies proof for a block at a specific index"},{"ref":"MerkleTree.Proof.html#t:proof_t/0","title":"MerkleTree.Proof.proof_t/0","type":"type","doc":""}]