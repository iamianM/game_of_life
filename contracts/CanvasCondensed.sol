// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct Node {
    uint k;
    uint n;
    uint hash;
    uint a;
    uint b;
    uint c;
    uint d; 
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

contract CanvasCondensed {
    Node   public on;
    Node   public off;
    Node   public head;
    uint mask = 9223372036854775807;
    uint   public kHead = 2;
    uint   public numCells = 4**kHead;
    uint   public lastUpdatedBlock;
    uint   public blocksToWait; 

    mapping(uint => Node)   public hashToNode;

    event lifeCount(uint n);

    constructor() {
        on.k = 0;
        on.n = 1;
        on.hash = 1;
        hashToNode[2] = on;

        off.k = 0;
        off.n = 0;
        off.hash = 2;
        hashToNode[1] = off;

        // create(numCells);
        // head = get_zero(kHead);
        // head = centre(head);
        lastUpdatedBlock = block.number;
        // blocksToWait = 1 << (head.k - 2);
    }

    function getHash(uint k, uint hashA, uint hashB, uint hashC, uint hashD) public view returns(uint) {
        uint nhash = (
            k
            + 2
            + 5131830419411 * hashA
            + 3758991985019 * hashB
            + 8973110871315 * hashC
            + 4318490180473 * hashD
        ) & mask;
        return nhash;
        // bytes memory r3 = abi.encodePacked(k, n, hashA, hashB, hashC, hashD);
    }

    function join(Node memory a, Node memory b, Node memory c, Node memory d)  public returns(Node memory) {
        /*
        Combine four children at level `k-1` to a new node at level `k`.
        If this is cached, return the cached node. 
        Otherwise, create a new node, and add it to the cache.
        */
        uint nhash = getHash(a.k, a.hash, b.hash, c.hash, d.hash);
        Node memory hashNode = hashToNode[nhash];
        if(hashNode.hash != 0) {
            return hashNode;
        }
        
        uint  n = a.n + b.n + c.n + d.n;
        Node memory result;
        result.k = a.k+1;
        result.n = n;
        result.hash = nhash;
        result.a = a.hash;
        result.b = b.hash;
        result.c = c.hash;
        result.d = d.hash;
        hashToNode[nhash] = result;
        return result;
    }

    function create(uint n) public returns(Node memory) {
        Node[4] memory nodes = [off, off, off, off];
        head = join(nodes[0], nodes[1], nodes[2], nodes[3]);
        n = n >> 2;
        while (n > 1) {
            head = join(head, head, head, head);
            n = n >> 2;
        }
        return head;
    }

    function activateNode(Node memory node, uint[] memory segments, uint j)    public returns(Node memory) {
        uint segment = segments[j]; 
        Node memory nodeA = hashToNode[node.a];
        Node memory nodeB = hashToNode[node.b];
        Node memory nodeC = hashToNode[node.c];
        Node memory nodeD = hashToNode[node.d];
        if (segment == 0) {
            if (segments.length - 1 == j) {
                return join(on, nodeB, nodeC, nodeD);
            } else {
                j++;
                return join(activateNode(nodeA, segments, j), nodeB, nodeC, nodeD);
            }
        } else if (segment == 1) {
            if (segments.length - 1 == j) {
                return join(nodeA, on, nodeC, nodeD);
            } else {
                j++;
                return join(nodeA, activateNode(nodeB, segments, j), nodeC, nodeD);
            }
        } else if (segment == 2) {
            if (segments.length - 1 == j) {
                return join(nodeA, nodeB, on, nodeD);
            } else {
                j++;
                return join(nodeA, nodeB, activateNode(nodeC, segments, j), nodeD);
            }
        } else {
            if (segments.length - 1 == j) {
                return join(nodeA, nodeB, nodeC, on);
            } else {
                j++;
                return join(nodeA, nodeB, nodeC, activateNode(nodeD, segments, j));
            }
        } 
    }

    function activateNodes(uint[][] memory segments) public {
        updateHead();
        Node memory headNew = head;
        for (uint i=0; i < segments.length; i++) {
            require(segments[i].length == head.k, "Not enough segments");
            headNew = activateNode(headNew, segments[i], 0);
        }
        head = headNew;
        lastUpdatedBlock = block.number;
    }

    function get_zero(uint k)    public returns(Node memory) {
        /*
        """Return an empty node at level `k`."""
        */
        if(k > 0) {
            return join(get_zero(k - 1), get_zero(k - 1), get_zero(k - 1), get_zero(k - 1));
        }
        else{
            return off;
        }
    }

    function centre(Node memory m)   public returns(Node memory){
        /*
        """Return a node at level `k+1`, which is centered on the given quadtree node."""
        */
        Node memory z = get_zero(hashToNode[m.a].k); // # get the right-sized zero node
        // Node memory z = off;
        // z.k = hashToNode[m.a].k;
        return join(
            join(z, z, z, hashToNode[m.a]), 
            join(z, z, hashToNode[m.b], z), 
            join(z, hashToNode[m.c], z, z), 
            join(hashToNode[m.d], z, z, z)
        );
    }

    function life(ns9 memory temp)    public returns(Node memory) {
        /*
        """The standard life rule, taking eight neighbours and a centre cell E.
        Returns on if should be on, and off otherwise."""
        */
        uint outer = temp.a_n + temp.b_n + temp.c_n + temp.d_n + temp.f_n + temp.g_n + temp.h_n + temp.i_n;
        emit lifeCount(outer);
        if ((temp.E_n != 0 && outer == 2) || outer == 3) {
            return on;
        } else {
            return off;
        }
    }

    function life_4x4(Node memory m)    public returns(Node memory){
        /*
        """
        Return the next generation of a $k=2$ (i.e. 4x4) cell. 
        To terminate the recursion, at the base level, 
        if we have a $k=2$ 4x4 block, 
        we can compute the 2x2 central successor by iterating over all 
        the 3x3 sub-neighbourhoods of 1x1 cells using the standard Life rule.
        """
        */
        ns4 memory temp = ns4(
            // life(ns9( 0,  0,  0,  0,  hashToNode[ hashToNode[m.a].a].n,  hashToNode[ hashToNode[m.a].b].n,  0,  hashToNode[ hashToNode[m.a].c].n,  hashToNode[ hashToNode[m.a].d].n)),  //# AA
            // life(ns9( hashToNode[ hashToNode[m.a].a].n,  hashToNode[ hashToNode[m.a].b].n,  hashToNode[ hashToNode[m.b].a].n,  hashToNode[ hashToNode[m.a].c].n,  hashToNode[ hashToNode[m.a].d].n,  hashToNode[ hashToNode[m.b].c].n,  hashToNode[ hashToNode[m.c].a].n,  hashToNode[ hashToNode[m.c].b].n,  hashToNode[ hashToNode[m.d].a].n)),  //# AB
            // life(ns9( hashToNode[ hashToNode[m.a].a].n,  hashToNode[ hashToNode[m.a].b].n,  hashToNode[ hashToNode[m.b].a].n,  hashToNode[ hashToNode[m.a].c].n,  hashToNode[ hashToNode[m.a].d].n,  hashToNode[ hashToNode[m.b].c].n,  hashToNode[ hashToNode[m.c].a].n,  hashToNode[ hashToNode[m.c].b].n,  hashToNode[ hashToNode[m.d].a].n)),  //# AC
            life(ns9( hashToNode[ hashToNode[m.a].a].n,  hashToNode[ hashToNode[m.a].b].n,  hashToNode[ hashToNode[m.b].a].n,  hashToNode[ hashToNode[m.a].c].n,  hashToNode[ hashToNode[m.a].d].n,  hashToNode[ hashToNode[m.b].c].n,  hashToNode[ hashToNode[m.c].a].n,  hashToNode[ hashToNode[m.c].b].n,  hashToNode[ hashToNode[m.d].a].n)),  //# AD
            life(ns9( hashToNode[ hashToNode[m.a].b].n,  hashToNode[ hashToNode[m.b].a].n,  hashToNode[ hashToNode[m.b].b].n,  hashToNode[ hashToNode[m.a].d].n,  hashToNode[ hashToNode[m.b].c].n,  hashToNode[ hashToNode[m.b].d].n,  hashToNode[ hashToNode[m.c].b].n,  hashToNode[ hashToNode[m.d].a].n,  hashToNode[ hashToNode[m.d].b].n)),  //# BC
            life(ns9( hashToNode[ hashToNode[m.a].c].n,  hashToNode[ hashToNode[m.a].d].n,  hashToNode[ hashToNode[m.b].c].n,  hashToNode[ hashToNode[m.c].a].n,  hashToNode[ hashToNode[m.c].b].n,  hashToNode[ hashToNode[m.d].a].n,  hashToNode[ hashToNode[m.c].c].n,  hashToNode[ hashToNode[m.c].d].n,  hashToNode[ hashToNode[m.d].c].n)),  //# CB
            life(ns9( hashToNode[ hashToNode[m.a].d].n,  hashToNode[ hashToNode[m.b].c].n,  hashToNode[ hashToNode[m.b].d].n,  hashToNode[ hashToNode[m.c].b].n,  hashToNode[ hashToNode[m.d].a].n,  hashToNode[ hashToNode[m.d].b].n,  hashToNode[ hashToNode[m.c].d].n,  hashToNode[ hashToNode[m.d].c].n,  hashToNode[ hashToNode[m.d].d].n))  //# DA
        );
        return join(temp.n1, temp.n2, temp.n3, temp.n4);
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
            Node[4] memory ms = [ hashToNode[m.a],  hashToNode[m.b],  hashToNode[m.c],  hashToNode[m.d]];
            Node[9] memory cs = [
                successor(join(hashToNode[ms[0].a], hashToNode[ ms[0].b], hashToNode[ ms[0].c], hashToNode[ms[0].d]), j),
                successor(join(hashToNode[ms[0].b], hashToNode[ ms[1].a], hashToNode[ ms[0].d], hashToNode[ms[1].c]), j),
                successor(join(hashToNode[ms[1].a], hashToNode[ ms[1].b], hashToNode[ ms[1].c], hashToNode[ms[1].d]), j),
                successor(join(hashToNode[ms[0].c], hashToNode[ ms[0].d], hashToNode[ ms[2].a], hashToNode[ms[2].b]), j),
                successor(join(hashToNode[ms[0].d], hashToNode[ ms[1].c], hashToNode[ ms[2].b], hashToNode[ms[3].a]), j),
                successor(join(hashToNode[ms[1].c], hashToNode[ ms[1].d], hashToNode[ ms[3].a], hashToNode[ms[3].b]), j),
                successor(join(hashToNode[ms[2].a], hashToNode[ ms[2].b], hashToNode[ ms[2].c], hashToNode[ms[2].d]), j),
                successor(join(hashToNode[ms[2].b], hashToNode[ ms[3].a], hashToNode[ ms[2].d], hashToNode[ms[3].c]), j),
                successor(join(hashToNode[ms[3].a], hashToNode[ ms[3].b], hashToNode[ ms[3].c], hashToNode[ms[3].d]), j)
            ];

            if (j < m.k - 2){
                s = join(
                    (join(hashToNode[cs[0].d], hashToNode[cs[1].c], hashToNode[cs[3].b], hashToNode[cs[4].a])),
                    (join(hashToNode[cs[1].d], hashToNode[cs[2].c], hashToNode[cs[4].b], hashToNode[cs[5].a])),
                    (join(hashToNode[cs[3].d], hashToNode[cs[4].c], hashToNode[cs[6].b], hashToNode[cs[7].a])),
                    (join(hashToNode[cs[4].d], hashToNode[cs[5].c], hashToNode[cs[7].b], hashToNode[cs[8].a]))
                );
            } else{
                s = join(
                    successor(join(cs[0], cs[1], cs[3], cs[4]), j),
                    successor(join(cs[1], cs[2], cs[4], cs[5]), j),
                    successor(join(cs[3], cs[4], cs[6], cs[7]), j),
                    successor(join(cs[4], cs[5], cs[7], cs[8]), j)
                );
            }
        }
        return s;
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
    
    function inner(Node memory node)    public returns(Node memory) {
        /*
        """
        Return the central portion of a node -- the inverse operation
        of centre()
        """
        */
        return join( hashToNode[ hashToNode[node.a].d],  hashToNode[ hashToNode[node.b].c],  hashToNode[ hashToNode[node.c].b],  hashToNode[ hashToNode[node.d].a]);
    }


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
        while (n > 0){
            nCopy = nCopy >> 1;
            // node = centre(node);
            i++;
        }
        //# apply the successor rule
        for (uint k=i - 1; k - 1 > 0; k--) {
            n = n >> 1;
            uint bit = (n & 1);
            if (bit != 0) {
                uint j = i - k - 1;
                node = successor(centre(node), j);
            }
        }
        return inner(node);
        // return node;
    }
    
    function updateHead() public {
        uint n = (block.number - lastUpdatedBlock) / blocksToWait;
        if (n != 0) {
            head = advance(head, n);
        }
    }

    function print(Node memory node)  public view returns(string memory) {
        if (node.k == 0) {
            if (node.n == 0) {
                return '.';
            } else {
                return 'X';
            }
        }
        return string(abi.encodePacked(print(hashToNode[node.a]), print(hashToNode[node.b]), print(hashToNode[node.c]), print(hashToNode[node.d])));
    }

    function print_head() public view returns(string memory) {
        return print(head);
    }


    function advance_one() public {
        /*
        """Advance node by exactly n generations, using
        the binary expansion of n to find the correct successors"""
        */
        head = successor(head, 0);
    }    
}