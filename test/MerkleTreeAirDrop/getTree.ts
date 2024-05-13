import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import fs from "fs";
// (1)
const tree = StandardMerkleTree.load(JSON.parse(fs.readFileSync("tree.json", "utf8")));

// (2)
for (const [i, v] of tree.entries()) {
  if (v[0] === "0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf") {
    // (3)
    const proof = tree.getProof(i);
    console.log("Value:", v);
    console.log("Proof:", proof);
  }
}

/*
Value: [ '0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf' ]
Proof: [
  '0xf14cf8fc603472005e1f5bc9f5e18b6afab9ae0c616620ded9018abc47b4e29d',
  '0xa585830a2256dbf43d5f2dc1705dba0a6ab8060db1fe3e24a7156300447e6d94'
]
*/
