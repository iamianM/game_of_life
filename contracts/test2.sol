// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// # The base quadtree node
// # `k` is the level of the node
// # `a, b, c, d` are the children of this node (or None, if `k=0`).
// # `n` is the number of on cells in this node (useful for bookkeeping and display)
// # `hash` is a precomputed hash of this node
// # (if we don't do this, Python will recursively compute the hash every time it is needed!)

struct Node {
    uint k;
    uint n;
    uint id;
    uint a;
    uint b;
    uint c;
    uint d; 
}

contract test2 {
    Node on;
    Node off;
    Node[] public nodes;

    mapping(uint => Node) hashToNode;
    event nodeCreated(Node);

    constructor() {
        on.k = 0;
        on.n = 1;
        off.k = 0;
        off.n = 0;
    }

    function create(uint n) public {
        nodes.push(off);
        nodes[0].id = 0;
        uint l_prev = 0;
        while (n != 1) {
            uint l = nodes.length;
            uint l_tot = l - l_prev;
            for (uint i=0; i < l_tot; i++) {
                nodes[l_prev + i].a = i*4 + l + 0;
                nodes[l_prev + i].b = i*4 + l + 1;
                nodes[l_prev + i].c = i*4 + l + 2;
                nodes[l_prev + i].d = i*4 + l + 3;
                nodes[l_prev + i].id = l_prev + i;
                nodes.push(off);
                nodes.push(off);
                nodes.push(off);
                nodes.push(off);
            }
            n = n / 4;
            l_prev = l;
        }
    }

    function create2(uint n) public {
        uint offset = 0;
        for (uint i=1; i < n + 1; i++) {
            Node memory temp = off;
            temp.id = i + offset;
            nodes.push(temp);
            uint leftover = i % 4;
            uint iTemp = i / 4;
            while (leftover == 0 && iTemp != 0) {
                iTemp = iTemp / 4;
                offset++;
                Node memory temp2 = off;
                temp2.id = i + offset;
                nodes.push(temp2);
                leftover = iTemp % 4;
            }
        }
    }

    function create3(uint n) public {
        uint offset = 0;
        for (uint i=1; i < n + 1; i++) {
            Node memory temp = off;
            temp.id = i + offset;
            nodes.push(temp);
            uint leftover = i % 4;
            uint iTemp = i / 4;
            while (leftover == 0 && iTemp != 0) {
                iTemp = iTemp / 4;
                offset++;
                Node memory temp2 = off;
                temp2.id = i + offset;
                nodes.push(temp2);
                leftover = iTemp % 4;
            }
        }
    }

}