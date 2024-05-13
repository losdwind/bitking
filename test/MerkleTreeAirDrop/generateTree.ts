import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
// import { SimpleMerkleTree } from "@openzeppelin/merkle-tree";

import fs from "fs";

// (1)
const values = [
  ["0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf", "1"],
  ["0xD08c8e6d78a1f64B1796d6DC3137B19665cb6F1F", "1"],
  ["0xb7D15753D3F76e7C892B63db6b4729f700C01298", "1"],
  ["0xf69Ca530Cd4849e3d1329FBEC06787a96a3f9A68", "1"],
  ["0xa8532aAa27E9f7c3a96d754674c99F1E2f824800", "1"],
];

// (2)
const tree = StandardMerkleTree.of(values, ["address", "uint256"]);
// const tree = SimpleMerkleTree.of([
//   keccak256("0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf"),
//   keccak256("0xD08c8e6d78a1f64B1796d6DC3137B19665cb6F1F"),
//   keccak256("0xb7D15753D3F76e7C892B63db6b4729f700C01298"),
//   keccak256("0xf69Ca530Cd4849e3d1329FBEC06787a96a3f9A68"),
//   keccak256("0xa8532aAa27E9f7c3a96d754674c99F1E2f824800"),
// ]);

// (3)
console.log("Merkle Root:", tree.root);

// (4)
fs.writeFileSync("tree.json", JSON.stringify(tree.dump()));

function keccak256(arg0: string): any {
  throw new Error("Function not implemented.");
}
// Merkle Root: 0x9eb275d84d6194e1166a3ba1cd07a7f2b2bbbee3df97eb9e353c541dfdc83a05
