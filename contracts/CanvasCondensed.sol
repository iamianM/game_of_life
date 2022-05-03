// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";

struct Node {
    uint k;
    bool alive;
    bytes32 hash;
    bytes32 a;
    bytes32 b;
    bytes32 c;
    bytes32 d; 
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
    bool a_n;
    bool b_n;
    bool c_n;
    bool d_n;
    bool E_n;
    bool f_n;
    bool g_n; 
    bool h_n; 
    bool i_n;
}

contract CanvasCondensed {
    Node public on = join(0, true, on.a, on.b, on.c, on.d);
    Node public off = join(0, false, off.a, off.b, off.c, off.d);
    Node public head;
    uint public kHead = 5;
    uint public numCells = 4**kHead;
    uint public lastUpdatedTimestamp;
    uint public minutesToWait; 
    event hashUsed(uint k, Node hashNode);

    mapping(bytes32 => Node) public hashToNode;

    event lifeCount(uint n);

    constructor() {
        create(numCells);
        lastUpdatedTimestamp = block.timestamp;
        minutesToWait = 1;
    }

    function getHash(uint k, bool alive, bytes32 hashA, bytes32 hashB, bytes32 hashC, bytes32 hashD) public view returns(bytes32) {
        return keccak256(abi.encodePacked(k, alive, hashA, hashB, hashC, hashD));
    }

    function join(uint k, bool alive, bytes32 hashA, bytes32 hashB, bytes32 hashC, bytes32 hashD) public returns(Node memory) {
        /*
        Combine four children at level `k-1` to a new node at level `k`.
        If this is cached, return the cached node. 
        Otherwise, create a new node, and add it to the cache.
        */
        bytes32 nhash = getHash(k, alive, hashA, hashB, hashC, hashD);
        bytes32 emptyHash;
        Node memory hashNode = hashToNode[nhash];
        if(hashNode.hash != emptyHash) {
            emit hashUsed(k, hashNode);
            return hashNode;
        }
        
        Node memory result = Node(k, alive, nhash, hashA, hashB, hashC, hashD);
        hashToNode[nhash] = result;
        return result;
    }

    function create(uint n) public {
        uint k = 1;
        Node memory newHead = join(k, false, off.hash, off.hash, off.hash, off.hash);
        n = n >> 2;
        while (n > 1) {
            k++;
            n = n >> 2;
            newHead = join(k, false, newHead.hash, newHead.hash, newHead.hash, newHead.hash);
        }
        head = newHead;
        kHead = k;
        numCells = 4**k;
    }

    function activateNode(Node memory node, uint[] memory segments, uint j) public returns(Node memory) {
        uint segment = segments[j]; 
        if (segment == 0) {
            if (segments.length - 1 == j) {
                return join(node.k, true, on.hash, node.b, node.c, node.d);
            } else {
                j++;
                Node memory nodeA = activateNode(hashToNode[node.a], segments, j);
                return join(node.k, true, nodeA.hash, node.b, node.c, node.d);
            }
        } else if (segment == 1) {
            if (segments.length - 1 == j) {
                return join(node.k, true, node.a, on.hash, node.c, node.d);
            } else {
                j++;
                Node memory nodeB = activateNode(hashToNode[node.b], segments, j);
                return join(node.k, true, node.a, nodeB.hash, node.c, node.d);
            }
        } else if (segment == 2) {
            if (segments.length - 1 == j) {
                return join(node.k, true, node.a, node.b, on.hash, node.d);
            } else {
                j++;
                Node memory nodeC = activateNode(hashToNode[node.c], segments, j);
                return join(node.k, true, node.a, node.b, nodeC.hash, node.d);
            }
        } else {
            if (segments.length - 1 == j) {
                return join(node.k, true, node.a, node.b, node.c, on.hash);
            } else {
                j++;
                Node memory nodeD = activateNode(hashToNode[node.d], segments, j);
                return join(node.k, true, node.a, node.b, node.c, nodeD.hash);
            }
        } 
    }

    function activateNodes(uint[][] memory segments) public {
        // updateHead();
        if (segments.length > 0) {
            Node memory newHead = head;
            for (uint i=0; i < segments.length; i++) {
                require(segments[i].length == head.k, "Not enough segments");
                newHead = activateNode(newHead, segments[i], 0);
            }
            head = newHead;
            // lastUpdatedTimestamp = block.timestamp;
        }
    }

    function centre(Node memory m) public returns(Node memory){
        /*
        """Return a node at level `k+1`, which is centered on the given quadtree node."""
        */
        Node memory newNode = join(m.k, m.alive, m.d, m.c, m.b, m.a);
        uint newK = m.k+1;
        return join(newK, newNode.alive, newNode.hash, newNode.hash, newNode.hash, newNode.hash);

    }

    function centre_head() public {
        head = centre(head);
    }

    function life(ns9 memory temp) public returns(Node memory) {
        /*
        """The standard life rule, taking eight neighbours and a centre cell E.
        Returns on if should be on, and off otherwise."""
        */
        uint outer;
        if(temp.a_n){outer++;}if(temp.b_n){outer++;}if(temp.c_n){outer++;}if(temp.d_n){outer++;}if(temp.f_n){outer++;}if(temp.g_n){outer++;}if(temp.h_n){outer++;}if(temp.i_n){outer++;}
        if ((temp.E_n && outer == 2) || outer == 3) {
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
        ns4 memory nodes = ns4(hashToNode[m.a], hashToNode[m.b], hashToNode[m.c], hashToNode[m.d]);
        ns4 memory nodesA = ns4(hashToNode[nodes.n1.a], hashToNode[nodes.n1.b], hashToNode[nodes.n1.c], hashToNode[nodes.n1.d]);
        ns4 memory nodesB = ns4(hashToNode[nodes.n2.a], hashToNode[nodes.n2.b], hashToNode[nodes.n2.c], hashToNode[nodes.n2.d]);
        ns4 memory nodesC = ns4(hashToNode[nodes.n3.a], hashToNode[nodes.n3.b], hashToNode[nodes.n3.c], hashToNode[nodes.n3.d]);
        ns4 memory nodesD = ns4(hashToNode[nodes.n4.a], hashToNode[nodes.n4.b], hashToNode[nodes.n4.c], hashToNode[nodes.n4.d]);
        ns4 memory newNode = ns4(
            life(ns9(nodesA.n1.alive, nodesA.n2.alive, nodesB.n1.alive, nodesA.n3.alive, nodesA.n4.alive,nodesB.n3.alive, nodesC.n1.alive, nodesC.n2.alive, nodesD.n1.alive)),  //# AD
            life(ns9(nodesA.n2.alive, nodesB.n1.alive, nodesB.n2.alive, nodesA.n4.alive, nodesB.n3.alive, nodesB.n4.alive, nodesC.n2.alive, nodesD.n1.alive, nodesD.n2.alive)),  //# BC
            life(ns9(nodesA.n3.alive, nodesA.n4.alive, nodesB.n3.alive, nodesC.n1.alive, nodesC.n2.alive, nodesD.n1.alive, nodesC.n3.alive, nodesC.n4.alive, nodesD.n3.alive)),  //# CB
            life(ns9(nodesA.n4.alive, nodesB.n3.alive, nodesB.n4.alive, nodesC.n2.alive, nodesD.n1.alive, nodesD.n2.alive, nodesC.n4.alive, nodesD.n3.alive, nodesD.n4.alive))  //# DA
        );
        bool alive = newNode.n1.alive || newNode.n2.alive || newNode.n3.alive || newNode.n4.alive;
        return join(newNode.n1.k+1, alive, newNode.n1.hash, newNode.n2.hash, newNode.n3.hash, newNode.n4.hash);
    }

    function successor(Node memory m, uint j)   public returns(Node memory) {
        /*
        """
        Return the 2**k-1 x 2**k-1 successor, 2**j generations in the future, 
        where j <= k - 2, caching the result.
        """
        */
        Node memory s;
        if (!m.alive){  //# empty
            return  hashToNode[m.a];
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
            ns4 memory ms = ns4(hashToNode[m.a], hashToNode[m.b], hashToNode[m.c], hashToNode[m.d]);
            ns4[4] memory msSub = [
                ns4(hashToNode[ms.n1.a], hashToNode[ms.n1.b], hashToNode[ms.n1.c], hashToNode[ms.n1.d]),
                ns4(hashToNode[ms.n2.a], hashToNode[ms.n2.b], hashToNode[ms.n2.c], hashToNode[ms.n2.d]),
                ns4(hashToNode[ms.n3.a], hashToNode[ms.n3.b], hashToNode[ms.n3.c], hashToNode[ms.n3.d]),
                ns4(hashToNode[ms.n4.a], hashToNode[ms.n4.b], hashToNode[ms.n4.c], hashToNode[ms.n4.d])
            ];
        
            Node[9] memory cs = [
                successor(ms.n1, j),
                successor(join(ms.n1.k, msSub[0].n2.alive || msSub[1].n1.alive || msSub[0].n4.alive || msSub[1].n3.alive, ms.n1.b, ms.n2.a, ms.n1.d, ms.n2.c), j),
                successor(join(ms.n1.k, msSub[1].n1.alive || msSub[1].n2.alive || msSub[1].n3.alive || msSub[1].n4.alive, ms.n2.a, ms.n2.b, ms.n2.c, ms.n2.d), j),
                successor(join(ms.n1.k, msSub[0].n3.alive || msSub[0].n4.alive || msSub[2].n1.alive || msSub[2].n2.alive, ms.n1.c, ms.n1.d, ms.n3.a, ms.n3.b), j),
                successor(join(ms.n1.k, msSub[0].n4.alive || msSub[1].n3.alive || msSub[2].n2.alive || msSub[3].n1.alive, ms.n1.d, ms.n2.c, ms.n3.b, ms.n4.a), j),
                successor(join(ms.n1.k, msSub[1].n3.alive || msSub[1].n4.alive || msSub[3].n1.alive || msSub[3].n2.alive, ms.n2.c, ms.n2.d, ms.n4.a, ms.n4.b), j),
                successor(join(ms.n1.k, msSub[2].n1.alive || msSub[2].n2.alive || msSub[2].n3.alive || msSub[2].n4.alive, ms.n3.a, ms.n3.b, ms.n3.c, ms.n3.d), j),
                successor(join(ms.n1.k, msSub[2].n2.alive || msSub[3].n1.alive || msSub[2].n4.alive || msSub[3].n3.alive, ms.n3.b, ms.n4.a, ms.n3.d, ms.n4.c), j),
                successor(ms.n4, j)
            ];

            if (j < m.k - 1){
                msSub = [
                    ns4(hashToNode[cs[0].d], hashToNode[cs[1].c], hashToNode[cs[3].b], hashToNode[cs[4].a]),
                    ns4(hashToNode[cs[1].d], hashToNode[cs[2].c], hashToNode[cs[4].b], hashToNode[cs[5].a]),
                    ns4(hashToNode[cs[3].d], hashToNode[cs[4].c], hashToNode[cs[6].b], hashToNode[cs[7].a]),
                    ns4(hashToNode[cs[4].d], hashToNode[cs[5].c], hashToNode[cs[7].b], hashToNode[cs[8].a])
                ];
                ms = ns4(
                    join(cs[1].k, msSub[0].n1.alive || msSub[0].n2.alive || msSub[0].n3.alive || msSub[0].n4.alive, cs[0].d, cs[1].c, cs[3].b, cs[4].a),
                    join(cs[1].k, msSub[0].n1.alive || msSub[0].n2.alive || msSub[0].n3.alive || msSub[0].n4.alive, cs[1].d, cs[2].c, cs[4].b, cs[5].a),
                    join(cs[1].k, msSub[0].n1.alive || msSub[0].n2.alive || msSub[0].n3.alive || msSub[0].n4.alive, cs[3].d, cs[4].c, cs[6].b, cs[7].a),
                    join(cs[1].k, msSub[0].n1.alive || msSub[0].n2.alive || msSub[0].n3.alive || msSub[0].n4.alive, cs[4].d, cs[5].c, cs[7].b, cs[8].a)
                );
                s = join(ms.n1.k+1, ms.n1.alive || ms.n2.alive || ms.n3.alive || ms.n4.alive, ms.n1.hash, ms.n2.hash, ms.n3.hash, ms.n4.hash);
            } else {
                ms = ns4(
                    successor(join(cs[0].k+1, cs[0].alive || cs[1].alive || cs[3].alive || cs[4].alive, cs[0].hash, cs[1].hash, cs[3].hash, cs[4].hash), j),
                    successor(join(cs[0].k+1, cs[1].alive || cs[2].alive || cs[4].alive || cs[5].alive, cs[1].hash, cs[2].hash, cs[4].hash, cs[5].hash), j),
                    successor(join(cs[0].k+1, cs[3].alive || cs[4].alive || cs[6].alive || cs[7].alive, cs[3].hash, cs[4].hash, cs[6].hash, cs[7].hash), j),
                    successor(join(cs[0].k+1, cs[4].alive || cs[5].alive || cs[7].alive || cs[8].alive, cs[4].hash, cs[5].hash, cs[7].hash, cs[8].hash), j)
                );
                s = join(ms.n1.k+1, ms.n1.alive || ms.n2.alive || ms.n3.alive || ms.n4.alive, ms.n1.hash, ms.n2.hash, ms.n3.hash, ms.n4.hash);
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
    //     return join( hashToNode[ hashToNode[node.a].d],  hashToNode[ hashToNode[node.b].c],  hashToNode[ hashToNode[node.c].b],  hashToNode[ hashToNode[node.d].a]);
    // }

    // function is_padded(Node memory node)   internal view returns(bool) {
    //     /*
    //     """
    //     True if the pattern is surrounded by at least one sub-sub-block of
    //     empty space.
    //     """
    //     */
    //     return (
    //         hashToNode[node.a].n ==  hashToNode[ hashToNode[ hashToNode[node.a].d].d].n
    //         &&  hashToNode[node.b].n ==  hashToNode[ hashToNode[ hashToNode[node.b].c].c].n
    //         &&  hashToNode[node.c].n ==  hashToNode[ hashToNode[ hashToNode[node.c].b].b].n
    //         &&  hashToNode[node.d].n ==  hashToNode[ hashToNode[ hashToNode[node.d].a].a].n
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

            if (!node.alive) {
                return string(abi.encodePacked(rep,'--', Strings.toString(x), ',', Strings.toString(y), ':O;'));
            } else {
                return string(abi.encodePacked(rep,'--', Strings.toString(x), ',', Strings.toString(y), ':X;'));
            }
        } else if (node.k == 1) {
            return string(abi.encodePacked(
            print(hashToNode[node.a], (x - 1)/2, (y - 1)/2, abi.encodePacked(string(rep), "0")), 
            print(hashToNode[node.b], (x + 1)/2, (y - 1)/2, abi.encodePacked(string(rep), "1")), 
            print(hashToNode[node.c], (x - 1)/2, (y + 1)/2, abi.encodePacked(string(rep), "2")), 
            print(hashToNode[node.d], (x + 1)/2, (y + 1)/2, abi.encodePacked(string(rep), "3")))
            );
        }
        uint offset = 2**(node.k - 1);
        return string(abi.encodePacked(
            print(hashToNode[node.a], x - offset, y - offset, abi.encodePacked(string(rep), "0")), 
            print(hashToNode[node.b], x + offset, y - offset, abi.encodePacked(string(rep), "1")), 
            print(hashToNode[node.c], x - offset, y + offset, abi.encodePacked(string(rep), "2")), 
            print(hashToNode[node.d], x + offset, y + offset, abi.encodePacked(string(rep), "3")))
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