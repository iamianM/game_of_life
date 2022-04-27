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
    uint hash;
    uint a;
    uint b;
    uint c;
    uint d; 
    uint treeId; 
    uint parent;
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

contract Canvas_old {
    Node on;
    Node off;
    uint mask = 9223372036854775807;

    Node[] public nodeTree;
    mapping(uint => Node) hashToNode;

    constructor() {
        on.k = 0;
        on.n = 1;
        on.hash = 1;
        off.k = 0;
        off.n = 0;
        off.hash = 0;
        create(16);
    }

    function join(Node memory a, Node memory b, Node memory c, Node memory d) private view returns(Node memory) {
        /*
        Combine four children at level `k-1` to a new node at level `k`.
        If this is cached, return the cached node. 
        Otherwise, create a new node, and add it to the cache.
        */
        uint  n = a.n + b.n + c.n + d.n;
        uint nhash = (
            a.k
            + 2
            + 5131830419411 * a.hash
            + 3758991985019 * b.hash
            + 8973110871315 * c.hash
            + 4318490180473 * d.hash
        ) & mask;
        Node memory hashNode = hashToNode[nhash];
        if(hashNode.hash != 0) {
            return hashNode;
        }

        Node memory result;
        result.k = a.k+1;
        result.n = n;
        result.hash = nhash;
        result.a = a.treeId;
        result.b = b.treeId;
        result.c = c.treeId;
        result.d = d.treeId;
        return result;
    }

    function get_zero(uint k) private view returns(Node memory) {
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

    function centre(Node memory m) private view returns(Node memory){
        /*
        """Return a node at level `k+1`, which is centered on the given quadtree node."""
        */
        Node memory z = get_zero(nodeTree[m.a].k); // # get the right-sized zero node
        return join(
            join(z, z, z, nodeTree[m.a]), 
            join(z, z, nodeTree[m.b], z), 
            join(z, nodeTree[m.c], z, z), 
            join(nodeTree[m.d], z, z, z)
        );
    }

    function life(ns9 memory temp) private view returns(Node memory) {
        /*
        """The standard life rule, taking eight neighbours and a centre cell E.
        Returns on if should be on, and off otherwise."""
        */
        uint outer = temp.a_n + temp.b_n + temp.c_n + temp.d_n + temp.f_n + temp.g_n + temp.h_n + temp.i_n;
        if ((temp.E_n != 0 && outer == 2) || outer == 3) {
            return on;
        } else {return off;}
    }

    function life_4x4(Node memory m) private view returns(Node memory){
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
            life(ns9(nodeTree[nodeTree[m.a].a].n, nodeTree[nodeTree[m.a].b].n, nodeTree[nodeTree[m.b].a].n, nodeTree[nodeTree[m.a].c].n, nodeTree[nodeTree[m.a].d].n, nodeTree[nodeTree[m.b].c].n, nodeTree[nodeTree[m.c].a].n, nodeTree[nodeTree[m.c].b].n, nodeTree[nodeTree[m.c].a].n)),  //# AD
            life(ns9(nodeTree[nodeTree[m.a].b].n, nodeTree[nodeTree[m.b].a].n, nodeTree[nodeTree[m.b].b].n, nodeTree[nodeTree[m.a].d].n, nodeTree[nodeTree[m.b].c].n, nodeTree[nodeTree[m.b].d].n, nodeTree[nodeTree[m.c].b].n, nodeTree[nodeTree[m.c].a].n, nodeTree[nodeTree[m.c].b].n)),  //# BC
            life(ns9(nodeTree[nodeTree[m.a].c].n, nodeTree[nodeTree[m.a].d].n, nodeTree[nodeTree[m.b].c].n, nodeTree[nodeTree[m.c].a].n, nodeTree[nodeTree[m.c].b].n, nodeTree[nodeTree[m.d].a].n, nodeTree[nodeTree[m.c].c].n, nodeTree[nodeTree[m.c].d].n, nodeTree[nodeTree[m.c].c].n)),  //# CB
            life(ns9(nodeTree[nodeTree[m.a].d].n, nodeTree[nodeTree[m.b].c].n, nodeTree[nodeTree[m.b].d].n, nodeTree[nodeTree[m.c].b].n, nodeTree[nodeTree[m.c].a].n, nodeTree[nodeTree[m.c].b].n, nodeTree[nodeTree[m.c].d].n, nodeTree[nodeTree[m.c].c].n, nodeTree[nodeTree[m.c].d].n))  //# DA
        );
        return join(temp.n1, temp.n2, temp.n3, temp.n4);
    }

    function successor(Node memory m, uint j) private view returns(Node memory) {
        /*
        """
        Return the 2**k-1 x 2**k-1 successor, 2**j generations in the future, 
        where j <= k - 2, caching the result.
        """
        */
        Node memory s;
        if (m.n == 0){  //# empty
            return nodeTree[m.a];
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
            Node[4] memory ms = [nodeTree[m.a], nodeTree[m.b], nodeTree[m.c], nodeTree[m.d]];
            Node[9] memory cs = [
                successor(join(nodeTree[ ms[0].a], nodeTree[ ms[0].b], nodeTree[ ms[0].c],  nodeTree[ms[0].d]), j),
                successor(join(nodeTree[ ms[0].b], nodeTree[ ms[1].a], nodeTree[ ms[0].d],  nodeTree[ms[1].c]), j),
                successor(join(nodeTree[ ms[1].a], nodeTree[ ms[1].b], nodeTree[ ms[1].c],  nodeTree[ms[1].d]), j),
                successor(join(nodeTree[ ms[0].c], nodeTree[ ms[1].d], nodeTree[ ms[2].a],  nodeTree[ms[2].b]), j),
                successor(join(nodeTree[ ms[0].d], nodeTree[ ms[1].c], nodeTree[ ms[2].b],  nodeTree[ms[3].a]), j),
                successor(join(nodeTree[ ms[1].c], nodeTree[ ms[1].d], nodeTree[ ms[3].a],  nodeTree[ms[3].b]), j),
                successor(join(nodeTree[ ms[2].a], nodeTree[ ms[2].b], nodeTree[ ms[2].c],  nodeTree[ms[2].d]), j),
                successor(join(nodeTree[ ms[2].b], nodeTree[ ms[3].a], nodeTree[ ms[2].d],  nodeTree[ms[3].c]), j),
                successor(join(nodeTree[ ms[3].a], nodeTree[ ms[3].b], nodeTree[ ms[3].c],  nodeTree[ms[3].d]), j)
            ];

            if (j < m.k - 2){
                s = join(
                    (join(nodeTree[cs[0].d], nodeTree[cs[1].c], nodeTree[cs[3].b], nodeTree[cs[4].a])),
                    (join(nodeTree[cs[1].d], nodeTree[cs[2].c], nodeTree[cs[4].b], nodeTree[cs[5].a])),
                    (join(nodeTree[cs[3].d], nodeTree[cs[4].c], nodeTree[cs[6].b], nodeTree[cs[7].a])),
                    (join(nodeTree[cs[4].d], nodeTree[cs[5].c], nodeTree[cs[7].b], nodeTree[cs[8].a]))
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

    function is_padded(Node memory node) private view returns(bool) {
        /*
        """
        True if the pattern is surrounded by at least one sub-sub-block of
        empty space.
        """
        */
        return (
            nodeTree[node.a].n == nodeTree[nodeTree[nodeTree[node.a].d].d].n
            && nodeTree[node.b].n == nodeTree[nodeTree[nodeTree[node.b].c].c].n
            && nodeTree[node.c].n == nodeTree[nodeTree[nodeTree[node.c].b].b].n
            && nodeTree[node.d].n == nodeTree[nodeTree[nodeTree[node.d].a].a].n
        );
    }

    function pad(Node memory node) private view returns(Node memory) {
        /*
        """
        Repeatedly centre a node, until it is fully padded.
        """
        */
        if (node.k <= 3 || !is_padded(node)){
            return pad(centre(node));
        } else {
            return node;
        }
    }

    function min(Point[] memory pts) private pure returns (uint256, uint256) {
        uint i = 0;
        uint256 minNumberX = pts[i].x;
        uint256 minNumberY = pts[i].y;

        while (i < pts.length) {
            if (pts[i].x < minNumberX) {
                minNumberX = pts[i].x;
            }
            if (pts[i].y < minNumberY) {
                minNumberY = pts[i].y;
            }
            i += 1;
        }

        return (minNumberX, minNumberY);
    }

    function create(uint n) public {
        nodeTree.push(off);
        nodeTree[0].treeId = 0;
        uint l_prev = 0;
        while (n != 1) {
            uint l = nodeTree.length;
            uint l_tot = l - l_prev;
            for (uint i=0; i < l_tot; i++) {
                nodeTree[l_prev + i].a = i*4 + l + 0;
                nodeTree[l_prev + i].b = i*4 + l + 1;
                nodeTree[l_prev + i].c = i*4 + l + 2;
                nodeTree[l_prev + i].d = i*4 + l + 3;
                nodeTree[l_prev + i].treeId = l_prev + i;
                nodeTree[l_prev + i].parent = l_prev;
                nodeTree.push(off);
                nodeTree.push(off);
                nodeTree.push(off);
                nodeTree.push(off);
            }
            n = n / 4;
            l_prev = l;
        }
    }
    
    // function construct(Point[] memory pts) private returns(Point[] memory){
    //     /*
    //     """
    //     Turn a list of (x,y) coordinates into a quadtree
    //     and return the top-level Node.
    //     """
    //     */
    //     //# Force start at (0,0)
    //     (uint256 min_x, uint256 min_y) = min(pts);
        
    //     Point[pts.length] memory pattern;
    //     uint k = 0;
    //     uint i = 0;
    //     while (i < pts.length) {
    //         Node temp = on;
    //         temp.x = pts[i].x - min_x;
    //         temp.y = pts[i].y - min_y;
    //         nodeTree.append(temp);
    //         i++;
    //     }
    //     uint j = i;
    //     i = 0;
    //     while (pattern.length != 1) {
    //         //# bottom-up construction
    //         Point[] next_level;
    //         uint z = get_zero(k);
    //         uint ij = i;
    //         while (ij < j) {
    //             uint x = pattern[ij].x;
    //             uint y = pattern[ij].y;
    //             x = x - (x & 1);
    //             y = y - (y & 1);
    //             //# read all 2x2 neighbours, removing from those to work through
    //             //# at least one of these must exist by definition
    //             a = pattern.pop((x, y), z);
    //             b = pattern.pop((x + 1, y), z);
    //             c = pattern.pop((x, y + 1), z);
    //             d = pattern.pop((x + 1, y + 1), z);
    //             next_level = join(a, b, c, d);
    //             nodeTree.append(next_level);
    //             ij++;
    //         }
    //         //# merge at the next level
    //         pattern = next_level;
    //         k += 1;
    //         i = j;
    //     }
    //     return pad(pattern.popitem()[1]);
    // }

    // function expand(Node memory node, uint x, uint y, uint[] memory clip, uint level) private view returns(Point[] memory) {
    //     /*
    //     """Turn a quadtree a list of (x,y,gray) triples 
    //     in the rectangle (x,y) -> (clip[0], clip[1]) (if clip is not-None).    
    //     If `level` is given, quadtree elements at the given level are given 
    //     as a grayscale level 0.0->1.0,  "zooming out" the display.
    //     """
    //     */

    //     if (node.n == 0) {  //# quick zero check
    //         Point[] memory result;
    //         return result;
    //     }
    //     uint size = 2 ** node.k;
    //     //# bounds check
    //     if (clip.length > 0) {
    //         if (x + size < clip[0] || x > clip[1] || y + size < clip[2] || y > clip[3]) {
    //             Point[] memory result;
    //             return result;
    //         }
    //     }
    //     if (node.k == 0) {
    //         //# base case: return the gray level of this node
    //         // uint gray = node.n / (size ** 2);
    //         // return [(x >> level, y >> level, gray)];
    //         Point[1] memory result = [Point(x >> level, y >> level)];
    //         return [Point(x >> level, y >> level)];
    //     } else {
    //         //# return all points contained inside this node
    //         uint offset = size >> 1;
    //         return (
    //             expand(node.a, x, y, clip, level)
    //             + expand(node.b, x + offset, y, clip, level)
    //             + expand(node.c, x, y + offset, clip, level)
    //             + expand(node.d, x + offset, y + offset, clip, level)
    //         );
    //     }
    // }

    function activateNodes(uint[] memory nodeIds) public {
        for (uint i=0; i < nodeIds.length; i++) {
            nodeTree[nodeIds[i]].n++;
        }
    }

    function ffwd(uint nodeId, uint n) public returns(Node memory, uint) {
        /*
        """Advance as quickly as possible, taking n 
        giant leaps"""
        */
        uint gens = 0;
        for (uint i=0; i < n; i++) {
            nodeTree[nodeId] = pad(nodeTree[nodeId]);
            gens += 1 << (nodeTree[nodeId].k - 2);
            nodeTree[nodeId] = successor(nodeTree[nodeId], 0);
        }
        return (nodeTree[nodeId], gens);
    }
    
    function inner(Node memory node) private view returns(Node memory) {
        /*
        """
        Return the central portion of a node -- the inverse operation
        of centre()
        """
        */
        return join(nodeTree[nodeTree[node.a].d], nodeTree[nodeTree[node.b].c], nodeTree[nodeTree[node.c].b], nodeTree[nodeTree[node.d].a]);
    }


    function crop(Node memory node) private returns(Node memory) {
        /*
        """
        Repeatedly take the inner node, until all padding is removed.
        """
        */
        if (node.k <= 3 || !is_padded(node)) {
            return node;
        } else{
            return crop(inner(node));
        }
    }


    function advance(uint nodeId, uint n) public returns(Node memory) {
        /*
        """Advance node by exactly n generations, using
        the binary expansion of n to find the correct successors"""
        */
        Node memory node = nodeTree[nodeId];
        if (n == 0) {
            return node;
        }
        uint[7] memory bits;
        uint i = 0;
        //# get the binary expansion, and pad sufficiently
        while (n > 0){
            bits[i] = (n & 1);
            n = n >> 1;
            node = centre(node);
            i++;
        }
        //# apply the successor rule
        for (uint k=bits.length - 1; k - 1 > 0; k--) {
            uint j = bits.length - k - 1;
            if (bits[k] != 0) {
                node = successor(node, j);
            }
        }
        return crop(node);
    }

    // function print_node(node) public view returns(string memory) {
    //     /*
    //     """
    //     Print out a node, fully expanded    
    //     """
    //     */
    //     Point[] memory points = expand(crop(node));
    //     uint px;
    //     uint py;
    //     for (uint i=0; i < n; i++) {
    //     for x, y, gray in sorted(points, key=lambda x: (x[1], x[0])):
    //         while y > py:
    //             print()
    //             py += 1
    //      px = 0
    //         while x > px:
    //             print(" ", end="")
    //             px += 1
    //         print("*", end="")
    //     }
    // }       
}