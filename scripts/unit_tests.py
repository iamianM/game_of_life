from brownie import accounts, network, CanvasCondensed, chain, config
import random
import json


cur_network = 'local'
accounts = accounts[:10]
account = accounts[0]

canvas = CanvasCondensed.deploy({"from": account})


def activateNodes_test():
    canvas.create(4**2, {"from": accounts[0]})
    oldHead = canvas.head()
    print(canvas.head())
    tx = canvas.activateNodes([[1,2], [2,0], [2,3], [3,0], [3,2]], {"from": accounts[0]})
    newHead = canvas.head()
    assert oldHead[0] == newHead[0], (oldHead[0], newHead[0])
    # actualHead = self.canvas.head()
    p = canvas.print_head()
    p = set([pp.split('--')[0] for pp in p.split(';')[:-1] if pp[-1] == 'X'])
    # trueP = set(['03', '31', '23', '30', '32'])
    trueP = set(['12', '20', '23', '30', '32'])
    assert p == trueP, (p,trueP)

def advance_one_test():
    canvas.create(4**2, {"from": accounts[0]})
    canvas.activateNodes([[1,2], [2,0], [2,3], [3,0], [3,2]], {"from": accounts[0]})
    # actualHead = self.canvas.head()
    canvas.advance_one()
    p = canvas.print_head()
    print(p)
    p = set([pp.split('--')[0] for pp in p.split(';')[:-1] if pp[-1] == 'X'])
    trueP = set(['03', '31', '23', '30', '32'])
    print( p, trueP)
    assert p == trueP

def life_test():
    n9 = (
        1,1,1,
        1,1,1,
        1,1,1
    )
    p = canvas.life(n9).return_value
    assert p[1] == 0

    n9 = (
        0,0,0,
        0,0,0,
        0,0,0
    )
    p = canvas.life(n9).return_value
    assert p[1] == 0

    n9 = (
        1,0,1,
        0,0,0,
        1,0,0
    )
    p = canvas.life(n9).return_value
    assert p[1] == 1

    n9 = (
        1,1,0,
        1,0,0,
        0,0,0
    )
    p = canvas.life(n9).return_value
    assert p[1] == 1

    n9 = (
        0,0,1,
        0,1,0,
        0,0,0
    )
    p = canvas.life(n9).return_value
    assert p[1] == 0

    n9 = (
        0,0,0,
        1,1,0,
        0,0,1
    )
    p = canvas.life(n9).return_value
    assert p[1] == 1

    n9 = (
        0,0,0,
        0,1,0,
        1,1,1
    )
    p = canvas.life(n9).return_value
    assert p[1] == 1

    n9 = (
        0,0,0,
        0,1,1,
        1,1,1
    )
    p = canvas.life(n9).return_value
    assert p[1] == 0

    n9 = (
        1,0,0,
        1,0,0,
        1,0,0
    )
    p = canvas.life(n9).return_value
    assert p[1] == 1

    n9 = (
        0,0,1,
        1,0,1,
        0,1,1
    )
    p = canvas.life(n9).return_value
    assert p[1] == 0

def life_4x4_test():
    n9 = (
        1,1,1,1,
        1,1,1,1,
        1,1,1,1,
        1,1,1,1
    )
    on = canvas.on()[2]
    off = canvas.off()[2]
    canvas.create(4**2, {"from": accounts[0]})
    canvas.activateNodes([
        [0,0], [0,1], [0,2], [0,3], 
        [1,0], [1,1], [1,2], [1,3],
        [2,0], [2,1], [2,2], [2,3],
        [3,0], [3,1], [3,2], [3,3],
    ], {"from": accounts[0]})
    p = canvas.life_4x4(canvas.head()).return_value
    assert p[3:] == (off,off,off,off), p[3:]

    n9 = (
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0
    )
    canvas.create(4**2, {"from": accounts[0]})
    p = canvas.life_4x4(canvas.head()).return_value
    assert p[3:] == (off,off,off,off), p[3:]

    n9 = (
        0,0,0,0,
        0,0,1,0,
        1,0,1,0,
        0,1,1,0
    )    
    n9 = (
        0,0,0,
        0,0,1,
        1,0,1
    )
    p = canvas.life(n9).return_value
    assert p[1] == True, p[1]
    
    canvas.create(4**2, {"from": accounts[0]})
    canvas.activateNodes([
        [1,2],
        [2,0], [2,2],
        [3,0], [3,2]
    ], {"from": accounts[0]})

    m = canvas.head()
    hashToNode = canvas.hashToNode
    n9True = (
        hashToNode(hashToNode(m[3])[3])[1], 
        hashToNode(hashToNode(m[3])[4])[1],  
        hashToNode(hashToNode(m[4])[3])[1], 
        hashToNode(hashToNode(m[3])[5])[1],  
        hashToNode(hashToNode(m[3])[6])[1], 
        hashToNode(hashToNode(m[4])[5])[1],
        hashToNode(hashToNode(m[5])[3])[1], 
        hashToNode(hashToNode(m[5])[4])[1], 
        hashToNode(hashToNode(m[6])[3])[1]
    )
    assert n9 == n9True, (n9, n9True)


    p = canvas.life_4x4(canvas.head()).return_value
    assert p[3:] == (on,off,off,on), p[3:]

    n9 = (
        0,0,1,0,
        1,0,1,0,
        0,1,1,0,
        0,0,0,0
    )
    canvas.create(4**2, {"from": accounts[0]})
    canvas.activateNodes([
        [0,2], 
        [1,0], [1,2], 
        [2,1], [3,0]
    ], {"from": accounts[0]})
    p = canvas.life_4x4(canvas.head()).return_value
    assert p[3:] == (off,on,on,on), p[3:]

    n9 = (
        1,0,0,0,
        0,1,1,0,
        1,1,0,0,
        0,0,0,0
    )
    canvas.create(4**2, {"from": accounts[0]})
    canvas.activateNodes([
        [0,0], [0,3],  
        [1,2], 
        [2,0], [2,1]
    ], {"from": accounts[0]})
    p = canvas.life_4x4(canvas.head()).return_value
    assert p[3:] == (off,on,on,on), p[3:]

def centre_test():
    canvas.create(4**2, {"from": accounts[0]})
    oldHead = canvas.head()
    print(oldHead)
    canvas.activateNodes([
        [1,2],
        [2,0], [2,3],
        [3,0], [3,2]
    ], {"from": accounts[0]})
    print(canvas.head())
    canvas.centre_head()
    newHead = canvas.head()
    assert newHead[0] == oldHead[0] + 1, (oldHead, newHead)
    hashToNode = canvas.hashToNode
    m = canvas.head()
    n9True = (
        hashToNode(hashToNode(hashToNode(m[3])[3])[3])[1], 
        hashToNode(hashToNode(hashToNode(m[3])[3])[4])[1], 
        hashToNode(hashToNode(hashToNode(m[3])[4])[3])[1],
        hashToNode(hashToNode(hashToNode(m[3])[4])[4])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[3])[3])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[3])[4])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[4])[3])[1],
        hashToNode(hashToNode(hashToNode(m[4])[4])[4])[1],

        hashToNode(hashToNode(hashToNode(m[3])[3])[5])[1], 
        hashToNode(hashToNode(hashToNode(m[3])[3])[6])[1], 
        hashToNode(hashToNode(hashToNode(m[3])[4])[5])[1],
        hashToNode(hashToNode(hashToNode(m[3])[4])[6])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[3])[5])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[3])[6])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[4])[5])[1],
        hashToNode(hashToNode(hashToNode(m[4])[4])[6])[1], 

        hashToNode(hashToNode(hashToNode(m[3])[5])[3])[1], 
        hashToNode(hashToNode(hashToNode(m[3])[5])[4])[1], 
        hashToNode(hashToNode(hashToNode(m[3])[6])[3])[1],
        hashToNode(hashToNode(hashToNode(m[3])[6])[4])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[5])[3])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[5])[4])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[6])[3])[1],
        hashToNode(hashToNode(hashToNode(m[4])[6])[4])[1],

        hashToNode(hashToNode(hashToNode(m[3])[5])[5])[1], 
        hashToNode(hashToNode(hashToNode(m[3])[5])[6])[1], 
        hashToNode(hashToNode(hashToNode(m[3])[6])[5])[1],
        hashToNode(hashToNode(hashToNode(m[3])[6])[6])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[5])[5])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[5])[6])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[6])[5])[1],
        hashToNode(hashToNode(hashToNode(m[4])[6])[6])[1], 

        hashToNode(hashToNode(hashToNode(m[5])[3])[3])[1], 
        hashToNode(hashToNode(hashToNode(m[5])[3])[4])[1], 
        hashToNode(hashToNode(hashToNode(m[5])[4])[3])[1],
        hashToNode(hashToNode(hashToNode(m[5])[4])[4])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[3])[3])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[3])[4])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[4])[3])[1],
        hashToNode(hashToNode(hashToNode(m[6])[4])[4])[1],

        hashToNode(hashToNode(hashToNode(m[5])[3])[5])[1], 
        hashToNode(hashToNode(hashToNode(m[5])[3])[6])[1], 
        hashToNode(hashToNode(hashToNode(m[5])[4])[5])[1],
        hashToNode(hashToNode(hashToNode(m[5])[4])[6])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[3])[5])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[3])[6])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[4])[5])[1],
        hashToNode(hashToNode(hashToNode(m[6])[4])[6])[1], 

        hashToNode(hashToNode(hashToNode(m[5])[5])[3])[1], 
        hashToNode(hashToNode(hashToNode(m[5])[5])[4])[1], 
        hashToNode(hashToNode(hashToNode(m[5])[6])[3])[1],
        hashToNode(hashToNode(hashToNode(m[5])[6])[4])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[5])[3])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[5])[4])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[6])[3])[1],
        hashToNode(hashToNode(hashToNode(m[6])[6])[4])[1],

        hashToNode(hashToNode(hashToNode(m[5])[5])[5])[1], 
        hashToNode(hashToNode(hashToNode(m[5])[5])[6])[1], 
        hashToNode(hashToNode(hashToNode(m[5])[6])[5])[1],
        hashToNode(hashToNode(hashToNode(m[5])[6])[6])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[5])[5])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[5])[6])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[6])[5])[1],
        hashToNode(hashToNode(hashToNode(m[6])[6])[6])[1], 
    )
    n9 = (
        1,0,1,0,1,0,1,0,
        1,0,0,1,1,0,0,1,
        0,0,0,0,0,0,0,0,
        1,0,0,0,1,0,0,0,
        1,0,1,0,1,0,1,0,
        1,0,0,1,1,0,0,1,
        0,0,0,0,0,0,0,0,
        1,0,0,0,1,0,0,0,
    )
    assert n9 == n9True, (n9, n9True)

def successor_test():
    n9 = (
        1,0,0,1,
        0,0,0,0,
        0,0,0,0,
        1,0,0,0
    )    
    canvas.create(4**2, {"from": accounts[0]})
    canvas.activateNodes([
        [0,0],
        [1,1], 
        [2,2],
    ], {"from": accounts[0]})
    canvas.centre_head()
    print(canvas.head())
    canvas.successor_head(1)
    m = canvas.head()
    hashToNode = canvas.hashToNode
    n9True = (
        hashToNode(hashToNode(m[3])[3])[1], 
        hashToNode(hashToNode(m[3])[4])[1], 
        hashToNode(hashToNode(m[4])[3])[1], 
        hashToNode(hashToNode(m[4])[4])[1],
        hashToNode(hashToNode(m[3])[5])[1], 
        hashToNode(hashToNode(m[3])[6])[1], 
        hashToNode(hashToNode(m[4])[5])[1], 
        hashToNode(hashToNode(m[4])[6])[1],
        hashToNode(hashToNode(m[5])[3])[1], 
        hashToNode(hashToNode(m[5])[4])[1], 
        hashToNode(hashToNode(m[6])[3])[1], 
        hashToNode(hashToNode(m[6])[4])[1],
        hashToNode(hashToNode(m[5])[5])[1], 
        hashToNode(hashToNode(m[5])[6])[1], 
        hashToNode(hashToNode(m[6])[5])[1], 
        hashToNode(hashToNode(m[6])[6])[1],
    )
    # n9New = (
    #     0,0,0,0,
    #     0,1,0,0,
    #     0,0,1,1,
    #     0,1,1,1
    # )
    n9New = (
        1,0,0,1,
        0,0,0,0,
        0,0,0,0,
        1,0,0,1
    )
    assert n9New == n9True, (n9New, n9True)

def advance_one_test():
    n9 = (
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,1,0,0,0,
        0,0,1,0,1,0,0,0,
        0,0,0,1,1,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
    )    
    canvas.create(4**3, {"from": accounts[0]})
    canvas.activateNodes([
        [1,2,2],
        [2,1,0], [2,1,3],
        [3,0,0], [3,0,2]
    ], {"from": accounts[0]})
    canvas.advance_one()
    m = canvas.head()
    hashToNode = canvas.hashToNode
    n9True = (
        hashToNode(hashToNode(hashToNode(m[3])[6])[3])[1], 
        hashToNode(hashToNode(hashToNode(m[3])[6])[4])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[5])[3])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[5])[4])[1],
        hashToNode(hashToNode(hashToNode(m[3])[6])[5])[1], 
        hashToNode(hashToNode(hashToNode(m[3])[6])[6])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[5])[5])[1], 
        hashToNode(hashToNode(hashToNode(m[4])[5])[6])[1],
        hashToNode(hashToNode(hashToNode(m[5])[4])[3])[1], 
        hashToNode(hashToNode(hashToNode(m[5])[4])[4])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[3])[3])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[3])[4])[1],
        hashToNode(hashToNode(hashToNode(m[5])[4])[5])[1], 
        hashToNode(hashToNode(hashToNode(m[5])[4])[6])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[3])[5])[1], 
        hashToNode(hashToNode(hashToNode(m[6])[3])[6])[1],
    )
    n9New = (
        0,0,0,0,
        0,1,0,0,
        0,0,1,1,
        0,1,1,0
    )

    ((
        0, 0, 0, 0, 
        0, 1, 0, 0, 
        0, 0, 1, 1, 
        0, 1, 1, 0
    ), (
        0, 0, 0, 0, 
        0, 0, 1, 0, 
        0, 0, 0, 1, 
        0, 1, 1, 1
    ))
    assert n9New == n9True, (n9New, n9True)

def print_test():
    canvas.create(4**3, {"from": accounts[0]})
    canvas.activateNodes([
        [1,2,2],
        [2,1,0], [2,1,3],
        [3,0,0], [3,0,2]
    ], {"from": accounts[0]})
    p = canvas.print_head()
    for pp in p.split(';')[:-1]:
        if pp.split('--')[0] in ['122', '210', '213', '300', '302']:
            assert pp.split(':')[1] == 'X', pp
        else:
            assert pp.split(':')[1] == 'O', pp
        if pp.split('--')[0] == '033':
            assert pp.split('--')[1].split(':')[0] == '3,3', pp
        if pp.split('--')[0] == '032':
            assert pp.split('--')[1].split(':')[0] == '2,3', pp
        if pp.split('--')[0] == '333':
            assert pp.split('--')[1].split(':')[0] == '7,7', pp
        if pp.split('--')[0] == '331':
            assert pp.split('--')[1].split(':')[0] == '7,6', pp

def size_test():
    # canvas.create(4**5, {"from": accounts[0]})
    # canvas.activateNodes([
    #     [0,1,2,3,0],
    # ], {"from": accounts[0]})
    # canvas.activateNodes([
    #     [3,2,1,2,2],
    #     [0,3,2,1,0], [3,0,2,1,3],
    #     [2,1,3,0,0], [2,1,3,0,2]
    # ], {"from": accounts[0]})


    # canvas.create(4**6, {"from": accounts[0]})
    # canvas.activateNodes([
    #     [0,1,2,3,0,1],
    # ], {"from": accounts[0]})
    # canvas.activateNodes([
    #     [1,3,2,1,2,2],
    #     [1,0,3,2,1,0], [1,3,0,2,1,3],
    #     [3,2,1,3,0,0], [2,2,1,3,0,2]
    # ], {"from": accounts[0]})

    
    # canvas.create(4**7, {"from": accounts[0]})
    # canvas.activateNodes([
    #     [0,1,2,3,0,1,2],
    # ], {"from": accounts[0]})
    # canvas.activateNodes([
    #     [2,1,3,2,1,2,2],
    #     [1,2,0,3,2,1,0], [3,3,3,0,2,1,3],
    #     [0,0,2,1,3,0,0], [1,3,2,1,3,0,2]
    # ], {"from": accounts[0]})

    
    # canvas.create(4**8, {"from": accounts[0]})
    # canvas.activateNodes([
    #     [0,1,2,3,0,1,2,3],
    # ], {"from": accounts[0]})
    # canvas.activateNodes([
    #     [0,2,1,3,2,1,2,2],
    #     [3,1,2,0,3,2,1,0], [1,3,3,3,0,2,1,3],
    #     [1,0,0,2,1,3,0,0], [2,1,3,2,1,3,0,2]
    # ], {"from": accounts[0]})

    
    canvas.create(4**9, {"from": accounts[0]})
    canvas.activateNodes([
        [0,1,2,3,0,1,2,3,0],
    ], {"from": accounts[0]})
    canvas.activateNodes([
        [0,0,2,1,3,2,1,2,2],
        [1,3,1,2,0,3,2,1,0], [3,1,3,3,3,0,2,1,3],
        [2,1,0,0,2,1,3,0,0], [0,2,1,3,2,1,3,0,2]
    ], {"from": accounts[0]})

    
    canvas.create(4**10, {"from": accounts[0]})
    canvas.activateNodes([
        [0,1,2,3,0,1,2,3,0,1],
    ], {"from": accounts[0]})
    canvas.activateNodes([
        [3,2,0,2,1,3,2,1,2,2],
        [1,2,3,1,2,0,3,2,1,0], [2,2,1,3,3,3,0,2,1,3],
        [3,0,1,0,0,2,1,3,0,0], [1,1,2,1,3,2,1,3,0,2]
    ], {"from": accounts[0]})



def main():
    # activateNodes_test()
    # advance_one_test()
    # life_test()
    # life_4x4_test()
    # centre_test()
    # successor_test()
    # print_test()
    size_test()