// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";

struct Node {
    uint k;
    uint n;
    bytes a;
    bytes b;
    bytes c;
    bytes d; 
}

struct Point {
    uint x;
    uint y; 
}

struct ns4 {
    Node n1;
    Node n2;
    Node n3;
    Node n4;
}

struct ns9 {
    uint a_n;
    uint b_n;
    uint c_n;
    uint d_n;
    uint E_n;
    uint f_n;
    uint g_n; 
    uint h_n; 
    uint i_n;
}

contract CanvasHashed {
    Node public on;
    Node public off;
    bytes public onHash;
    bytes public offHash;
    Node public head;
    uint public kHead = 5;
    uint public numCells = 4**kHead;
    uint public lastUpdatedTimestamp;
    uint public minutesToWait; 

    constructor() {
        on.k = 0;
        on.n = 1;
        onHash = getHash(on);

        off.k = 0;
        off.n = 0;
        offHash = getHash(on);

        // create(numCells);
        lastUpdatedTimestamp = block.timestamp;
        minutesToWait = 1;
    }

    function getMSGData() public view returns(bytes memory) {
        return msg.data;
    }

    function test() public view returns(bytes32,bytes memory) {
        return abi.decode(
            abi.encodePacked(bytes28(0), msg.data),
            (bytes32,bytes)
        );
    }

    function getHash(Node memory node) public view returns(bytes memory) {
        return abi.encode(bytes28(0), node.k, node.n, node.a, node.b, node.c, node.d);
    }
    // function getHash2(Node memory node) public view returns(bytes memory, bytes memory, bytes memory, bytes memory, bytes memory, bytes memory, bytes memory) {
    //     return (abi.encode(
    //         bytes28(0), abi.encodePacked(node.k), abi.encodePacked(node.n), abi.encodePacked(node.a), 
    //         abi.encodePacked(node.b), abi.encodePacked(node.c), abi.encodePacked(node.d)
    //         ),abi.encodePacked(node.k), abi.encodePacked(node.n), abi.encodePacked(node.a), 
    //         abi.encodePacked(node.b), abi.encodePacked(node.c), abi.encodePacked(node.d)
    //         );
    // }
    // function getHash2(Node memory node) public view returns(bytes32) {
    //     return abi.decodeParameters((uint, uint, bytes, bytes, bytes, bytes), keccak256(abi.encodePacked(bytes28(0), node.k, node.n, node.a, node.b, node.c, node.d)));
    // }

    // function getHash3(uint k, uint n, bytes memory a, bytes memory b, bytes memory c, bytes memory d) public view returns(bytes memory) {
    //     return abi.encodePacked(bytes28(0), k, n, a, b, c, d);
    // }
    
    // function getHash(uint k, uint n, bytes memory a, bytes memory b, bytes memory c, bytes memory d) public view returns(bytes memory) {
    //     return abi.encodePacked(bytes28(0), k, n, a, b, c, d);
    // }

    function getUnhash(bytes memory b) public view returns(Node memory) {
        (bytes32 temp, uint k, uint n, bytes memory hashA, bytes memory hashB, bytes memory hashC, bytes memory hashD) = abi.decode(b, (bytes32, uint, uint, bytes, bytes, bytes, bytes));
        return Node(k, n, hashA, hashB, hashC, hashD);
    }

    // function getHash2(Node memory node) public view returns(bytes memory) {
    //     return abi.encode(node.k, node.n, node.a, node.b, node.c, node.d);
    // }

    // function getUnhash(bytes memory b) public view returns(Node memory) {
    //     (uint k, uint n, bytes memory hashA, bytes memory hashB, bytes memory hashC, bytes memory hashD) = abi.decode(b, (uint, uint, bytes, bytes, bytes, bytes));
    //     return Node(k, n, hashA, hashB, hashC, hashD);
    // }

    // function join(Node memory a, Node memory b, Node memory c, Node memory d) public view returns(Node memory) {
    //     return Node(a.k+1, a.n + b.n + c.n + d.n, getHash(a), getHash(b), getHash(c), getHash(d));
    // }

    // function join(k, n, bytes memory a, bytes memory b, bytes memory c, bytes memory d) public view returns(Node memory) {
    //     return Node(k, n, a, b, c, d);
    // }

    function create(uint n) public returns(Node memory) {
        // Node[4] memory nodes = [off, off, off, off];
        uint k = 1;
        head = Node(k, 0, offHash, offHash, offHash, offHash);
        bytes memory headHash;
        n = n >> 2;
        while (n > 1) {
            headHash = getHash(head);
            k++;
            n = n >> 2;
            head = Node(k, 0, headHash, headHash, headHash, headHash);
        }
        kHead = k;
        numCells = 4**k;
        return head;
    }

    function activateNode(Node memory node, uint[] memory segments, uint j) public returns(Node memory) {
        uint segment = segments[j]; 
        Node memory nodeA = getUnhash(node.a);
        Node memory nodeB = getUnhash(node.b);
        Node memory nodeC = getUnhash(node.c);
        Node memory nodeD = getUnhash(node.d);
        if (segment == 0) {
            if (segments.length - 1 == j) {
                uint n = nodeB.n + nodeC.n + nodeD.n + 1;
                return Node(node.k, n, onHash, node.b, node.c, node.d);
            } else {
                j++;
                nodeA = activateNode(nodeA, segments, j);
                uint n = nodeA.n + nodeB.n + nodeC.n + nodeD.n;
                return Node(node.k, n, getHash(nodeA), node.b, node.c, node.d);
            }
        } else if (segment == 1) {
            if (segments.length - 1 == j) {
                uint n = nodeA.n + nodeC.n + nodeD.n + 1;
                return Node(node.k, n, node.a, onHash, node.c, node.d);
            } else {
                j++;
                nodeB = activateNode(nodeB, segments, j);
                uint n = nodeA.n + nodeB.n + nodeC.n + nodeD.n;
                return Node(node.k, n, node.a, getHash(nodeB), node.c, node.d);
            }
        } else if (segment == 2) {
            if (segments.length - 1 == j) {
                uint n = nodeA.n + nodeB.n + nodeD.n + 1;
                return Node(node.k, n, node.a, node.b, onHash, node.d);
            } else {
                j++;
                nodeC = activateNode(nodeC, segments, j);
                uint n = nodeA.n + nodeB.n + nodeC.n + nodeD.n;
                return Node(node.k, n, node.a, node.b, getHash(nodeC), node.d);
            }
        } else {
            if (segments.length - 1 == j) {
                uint n = nodeA.n + nodeB.n + nodeC.n + 1;
                return Node(node.k, n, node.a, node.b, node.c, onHash);
            } else {
                j++;
                nodeD = activateNode(nodeD, segments, j);
                uint n = nodeA.n + nodeB.n + nodeC.n + nodeD.n;
                return Node(node.k, n, node.a, node.b, node.c, getHash(nodeD));
            }
        } 
    }

    function activateNodes(uint[][] memory segments) public {
        // updateHead();
        Node memory headNew = head;
        for (uint i=0; i < segments.length; i++) {
            require(segments[i].length == head.k, "Not enough segments");
            headNew = activateNode(headNew, segments[i], 0);
        }
        head = headNew;
        lastUpdatedTimestamp = block.timestamp;
    }

    function centre(Node memory m) public returns(Node memory){
        /*
        """Return a node at level `k+1`, which is centered on the given quadtree node."""
        */
        // ns4 memory nodes = ns4(getUnhash(m.a), getUnhash(m.b), getUnhash(m.c), getUnhash(m.d));
        bytes memory newNodeHash = getHash(Node(m.k, m.n, m.d, m.c, m.b, m.a));
        return Node(m.k+1, m.n, newNodeHash, newNodeHash, newNodeHash, newNodeHash);

    }

    function centre_head() public {
        head = centre(head);
    }

    function life(ns9 memory temp) public returns(Node memory) {
        /*
        """The standard life rule, taking eight neighbours and a centre cell E.
        Returns on if should be on, and off otherwise."""
        */
        uint outer = temp.a_n + temp.b_n + temp.c_n + temp.d_n + temp.f_n + temp.g_n + temp.h_n + temp.i_n;
        if ((temp.E_n != 0 && outer == 2) || outer == 3) {
            return on;
        } else {
            return off;
        }
    }

    function life_4x4(Node memory m) public returns(Node memory){
        /*
        """
        Return the next generation of a $k=2$ (i.e. 4x4) cell. 
        To terminate the recursion, at the base level, 
        if we have a $k=2$ 4x4 block, 
        we can compute the 2x2 central successor by iterating over all 
        the 3x3 sub-neighbourhoods of 1x1 cells using the standard Life rule.
        """
        */
        
        ns4 memory nodes = ns4(getUnhash(m.a), getUnhash(m.b), getUnhash(m.c), getUnhash(m.d));
        ns4 memory nodesA = ns4(getUnhash(nodes.n1.a), getUnhash(nodes.n1.b), getUnhash(nodes.n1.c), getUnhash(nodes.n1.d));
        ns4 memory nodesB = ns4(getUnhash(nodes.n2.a), getUnhash(nodes.n2.b), getUnhash(nodes.n2.c), getUnhash(nodes.n2.d));
        ns4 memory nodesC = ns4(getUnhash(nodes.n3.a), getUnhash(nodes.n3.b), getUnhash(nodes.n3.c), getUnhash(nodes.n3.d));
        ns4 memory nodesD = ns4(getUnhash(nodes.n4.a), getUnhash(nodes.n4.b), getUnhash(nodes.n4.c), getUnhash(nodes.n4.d));
        ns4 memory temp = ns4(
            life(ns9(nodesA.n1.n, nodesA.n2.n, nodesB.n1.n, nodesA.n3.n,  nodesA.n4.n,  nodesB.n3.n,  nodesC.n1.n,  nodesC.n2.n, nodesD.n1.n)),  //# AD
            life(ns9(nodesA.n2.n, nodesB.n1.n, nodesB.n2.n, nodesA.n4.n,  nodesB.n3.n,  nodesB.n4.n,  nodesC.n2.n,  nodesD.n1.n, nodesD.n2.n)),  //# BC
            life(ns9(nodesA.n3.n, nodesA.n4.n, nodesB.n3.n, nodesC.n1.n,  nodesC.n2.n,  nodesD.n1.n,  nodesC.n3.n,  nodesC.n4.n, nodesD.n3.n)),  //# CB
            life(ns9(nodesA.n4.n, nodesB.n3.n, nodesB.n4.n, nodesC.n2.n,  nodesD.n1.n,  nodesD.n2.n,  nodesC.n4.n,  nodesD.n3.n, nodesD.n4.n))  //# DA
        );
        return Node(temp.n1.k+1, temp.n1.n + temp.n2.n + temp.n3.n + temp.n4.n, getHash(temp.n1), getHash(temp.n2), getHash(temp.n3), getHash(temp.n4));
    }

    function successor(Node memory m, uint j)   public returns(Node memory) {
        /*
        """
        Return the 2**k-1 x 2**k-1 successor, 2**j generations in the future, 
        where j <= k - 2, caching the result.
        """
        */
        Node memory s;
        if (m.n == 0){  //# empty
            return  getUnhash(m.a);
        } else if (m.k == 2) {  //# base case
            s = life_4x4(m);
        } else{
            if (j == 0) {
                j = m.k - 2;
            } else{
                uint jNew = m.k - 2;
                if (jNew < j) {
                    j = jNew;
                }
            }
            ns4 memory ms = ns4(getUnhash(m.a), getUnhash(m.b), getUnhash(m.c), getUnhash(m.d));
            ns4[4] memory msSub = [
                ns4(getUnhash(ms.n1.a), getUnhash(ms.n1.b), getUnhash(ms.n1.c), getUnhash(ms.n1.d)),
                ns4(getUnhash(ms.n2.a), getUnhash(ms.n2.b), getUnhash(ms.n2.c), getUnhash(ms.n2.d)),
                ns4(getUnhash(ms.n3.a), getUnhash(ms.n3.b), getUnhash(ms.n3.c), getUnhash(ms.n3.d)),
                ns4(getUnhash(ms.n4.a), getUnhash(ms.n4.b), getUnhash(ms.n4.c), getUnhash(ms.n4.d))
            ];
        
            Node[9] memory cs = [
                successor(ms.n1, j),
                successor(Node(ms.n1.k, msSub[0].n2.n + msSub[1].n1.n + msSub[0].n4.n + msSub[1].n3.n, ms.n1.b, ms.n2.a, ms.n1.d, ms.n2.d), j),
                successor(Node(ms.n1.k, msSub[1].n1.n + msSub[1].n2.n + msSub[1].n3.n + msSub[1].n4.n, ms.n2.a, ms.n2.b, ms.n2.c, ms.n2.d), j),
                successor(Node(ms.n1.k, msSub[0].n3.n + msSub[0].n4.n + msSub[2].n1.n + msSub[2].n2.n, ms.n1.c, ms.n1.d, ms.n3.a, ms.n3.b), j),
                successor(Node(ms.n1.k, msSub[0].n4.n + msSub[1].n3.n + msSub[2].n2.n + msSub[3].n1.n, ms.n1.d, ms.n2.c, ms.n3.b, ms.n4.a), j),
                successor(Node(ms.n1.k, msSub[1].n3.n + msSub[1].n4.n + msSub[3].n1.n + msSub[3].n2.n, ms.n2.c, ms.n2.d, ms.n4.a, ms.n4.b), j),
                successor(Node(ms.n1.k, msSub[2].n1.n + msSub[2].n2.n + msSub[2].n3.n + msSub[2].n4.n, ms.n3.a, ms.n3.b, ms.n3.c, ms.n3.d), j),
                successor(Node(ms.n1.k, msSub[2].n2.n + msSub[3].n1.n + msSub[2].n4.n + msSub[3].n3.n, ms.n3.b, ms.n4.a, ms.n3.d, ms.n4.c), j),
                successor(ms.n4, j)
            ];

            if (j < m.k - 1){
                msSub = [
                    ns4(getUnhash(cs[0].d), getUnhash(cs[1].c), getUnhash(cs[3].b), getUnhash(cs[4].a)),
                    ns4(getUnhash(cs[1].d), getUnhash(cs[2].c), getUnhash(cs[4].b), getUnhash(cs[5].a)),
                    ns4(getUnhash(cs[3].d), getUnhash(cs[4].c), getUnhash(cs[6].b), getUnhash(cs[7].a)),
                    ns4(getUnhash(cs[4].d), getUnhash(cs[5].c), getUnhash(cs[7].b), getUnhash(cs[8].a))
                ];
                ms = ns4(
                    Node(cs[1].k, msSub[0].n1.n + msSub[0].n2.n + msSub[0].n3.n + msSub[0].n4.n, cs[0].d, cs[1].c, cs[3].b, cs[4].a),
                    Node(cs[1].k, msSub[0].n1.n + msSub[0].n2.n + msSub[0].n3.n + msSub[0].n4.n, cs[1].d, cs[2].c, cs[4].b, cs[5].a),
                    Node(cs[1].k, msSub[0].n1.n + msSub[0].n2.n + msSub[0].n3.n + msSub[0].n4.n, cs[3].d, cs[4].c, cs[6].b, cs[7].a),
                    Node(cs[1].k, msSub[0].n1.n + msSub[0].n2.n + msSub[0].n3.n + msSub[0].n4.n, cs[4].d, cs[5].c, cs[7].b, cs[8].a)
                );
                s = Node(ms.n1.k+1, ms.n1.n+ms.n2.n+ms.n3.n+ms.n4.n, getHash(ms.n1), getHash(ms.n2), getHash(ms.n3), getHash(ms.n4));
            } else {
                bytes[9] memory hashes = [getHash(cs[0]), getHash(cs[1]), getHash(cs[2]), getHash(cs[3]), getHash(cs[4]), getHash(cs[5]), getHash(cs[6]), getHash(cs[7]), getHash(cs[8])];
                ms = ns4(
                    successor(Node(cs[0].k+1, cs[0].n + cs[1].n + cs[3].n + cs[4].n, hashes[0], hashes[1], hashes[3], hashes[4]), j),
                    successor(Node(cs[0].k+1, cs[1].n + cs[2].n + cs[4].n + cs[5].n, hashes[1], hashes[2], hashes[4], hashes[5]), j),
                    successor(Node(cs[0].k+1, cs[3].n + cs[4].n + cs[6].n + cs[7].n, hashes[3], hashes[4], hashes[6], hashes[7]), j),
                    successor(Node(cs[0].k+1, cs[4].n + cs[5].n + cs[7].n + cs[8].n, hashes[4], hashes[5], hashes[7], hashes[8]), j)
                );
                s = Node(ms.n1.k+1, ms.n1.n+ms.n2.n+ms.n3.n+ms.n4.n, getHash(ms.n1), getHash(ms.n2), getHash(ms.n3), getHash(ms.n4));
            }
        }
        return s;
    }

    function successor_head(uint j) public {
        head = successor(head, j);
    }

    function ffwd(Node memory node, uint n)   public returns(Node memory) {
        /*
        """Advance as quickly as possible, taking n 
        giant leaps"""
        */
        for (uint i=0; i < n; i++) {
            node = successor(centre(node), 0);
        }
        return node;
    }
    
    // function inner(Node memory node)    public returns(Node memory) {
    //     /*
    //     """
    //     Return the central portion of a node -- the inverse operation
    //     of centre()
    //     """
    //     */
    //     return join(getUnhash(getUnhash(node.a).d), getUnhash(getUnhash(node.b).c), getUnhash(getUnhash(node.c).b), getUnhash(getUnhash(node.d).a));
    // }

    // function is_padded(Node memory node)   internal view returns(bool) {
    //     /*
    //     """
    //     True if the pattern is surrounded by at least one sub-sub-block of
    //     empty space.
    //     """
    //     */
    //     return (
    //         getUnhash(node.a).n ==  getUnhash( getUnhash( getUnhash(node.a).d).d).n
    //         && getUnhash(node.b).n == getUnhash(getUnhash(getUnhash(node.b).c).c).n
    //         && getUnhash(node.c).n == getUnhash(getUnhash(getUnhash(node.c).b).b).n
    //         && getUnhash(node.d).n == getUnhash(getUnhash(getUnhash(node.d).a).a).n
    //     );
    // }


    // function crop(Node memory node)   internal returns(Node memory) {
    //     /*
    //     """
    //     Repeatedly take the inner node, until all padding is removed.
    //     """
    //     */
    //     if (node.k <= 3 || !is_padded(node)) {
    //         return node;
    //     } else{
    //         return crop(inner(node));
    //     }
    // }


    function advance(Node memory node, uint n)  public returns(Node memory) {
        /*
        """Advance node by exactly n generations, using
        the binary expansion of n to find the correct successors"""
        */
        // Node memory node =  head;
        if (n == 0) {
            return node;
        }
        uint nCopy = n;
        uint i = 0;
        //# get the binary expansion, and pad sufficiently
        while (nCopy > 0){
            nCopy = nCopy >> 1;
            node = centre(node);
            i++;
        }
        //# apply the successor rule
        for (uint k=i; k > 0; k--) {
            uint bit = (n & 1);
            n = n >> 1;
            if (bit != 0) {
                uint j = i - k;
                node = successor(node, j);
            }
        }
        return node;
        // return crop(node);
    }

    function temp2(uint n, uint i) public returns(uint) {
        uint bit;
        uint j;
        for (uint k=i; k > 0; k--) {
            n = n / 4;
            bit = (n & 1);
            if (bit != 0) {
                j = i - k;
                head = successor(centre(head), j);
            }
        }
        return j;
    }

    function getTimeDiff() public view returns (uint) {
        return (block.timestamp - lastUpdatedTimestamp) / (minutesToWait * 60);
    }
    
    function updateHead() public {
        uint n = getTimeDiff();
        if (n != 0) {
            head = advance(head, n);
        }
    }

    function print(Node memory node, uint x, uint y, bytes memory rep) public view returns(string memory) {
        if (node.k == 0) {

            if (node.n == 0) {
                return string(abi.encodePacked(rep,'--', Strings.toString(x), ',', Strings.toString(y), ':O;'));
            } else {
                return string(abi.encodePacked(rep,'--', Strings.toString(x), ',', Strings.toString(y), ':X;'));
            }
        } else if (node.k == 1) {
            return string(abi.encodePacked(
            print(getUnhash(node.a), (x - 1)/2, (y - 1)/2, abi.encodePacked(string(rep), "0")), 
            print(getUnhash(node.b), (x + 1)/2, (y - 1)/2, abi.encodePacked(string(rep), "1")), 
            print(getUnhash(node.c), (x - 1)/2, (y + 1)/2, abi.encodePacked(string(rep), "2")), 
            print(getUnhash(node.d), (x + 1)/2, (y + 1)/2, abi.encodePacked(string(rep), "3")))
            );
        }
        uint offset = 2**(node.k - 1);
        return string(abi.encodePacked(
            print(getUnhash(node.a), x - offset, y - offset, abi.encodePacked(string(rep), "0")), 
            print(getUnhash(node.b), x + offset, y - offset, abi.encodePacked(string(rep), "1")), 
            print(getUnhash(node.c), x - offset, y + offset, abi.encodePacked(string(rep), "2")), 
            print(getUnhash(node.d), x + offset, y + offset, abi.encodePacked(string(rep), "3")))
        );
    }

    function print_head() public view returns(string memory) {
        return print(head, (numCells >> kHead) - 1, (numCells >> kHead) - 1, abi.encodePacked(""));
    }


    function advance_one() public {
        /*
        """Advance node by exactly n generations, using
        the binary expansion of n to find the correct successors"""
        */
        head = successor(centre(head), 1);
    }    
}