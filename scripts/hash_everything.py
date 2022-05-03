from brownie import accounts, network, CanvasHashed, chain, config
import random
import json
import itertools

LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["hardhat",
                                 "development", "ganache", "mainnet-fork"]

use_previous = True
previous = json.load(open('previous.json'))
if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
    publish_source = False
    cur_network = 'local'
    accounts = accounts[:10]
    account = accounts[0]
else:
    publish_source = True
    cur_network = network.show_active()
    accounts.load("main")
    account = accounts[0]

if(use_previous):
    canvas = CanvasHashed.at(previous[cur_network]['canvas'])
else:
    canvas = CanvasHashed.deploy({"from": account})
        # {"from": account}, publish_source=publish_source)

if cur_network not in previous:
    previous[cur_network] = {}
previous[cur_network] = {
    'canvas': canvas.address
}
json.dump(previous, open('previous.json', 'w'))

head = canvas.head()

k = 0
allHashes = {kk: {"ns": [], "hashes": []} for kk in range(head.k+1)}
allHashes[0]["hashes"].append(canvas.getHash(k,0,0,0,0))
allHashes[0]["ns"].append(0)
allHashes[0].append(canvas.getHash(k,1,0,0,0))
allHashes[0]["ns"].append(1)
allHashes[0].append(canvas.getHash(k,0,1,0,0))
allHashes[0]["ns"].append(1)
allHashes[0].append(canvas.getHash(k,0,0,1,0))
allHashes[0]["ns"].append(1)
allHashes[0].append(canvas.getHash(k,0,0,0,1))
allHashes[0]["ns"].append(1)
allHashes[0].append(canvas.getHash(k,1,1,0,0))
allHashes[0]["ns"].append(2)
allHashes[0].append(canvas.getHash(k,1,0,1,0))
allHashes[0]["ns"].append(2)
allHashes[0].append(canvas.getHash(k,1,0,0,1))
allHashes[0]["ns"].append(2)
allHashes[0].append(canvas.getHash(k,0,1,1,0))
allHashes[0]["ns"].append(2)
allHashes[0].append(canvas.getHash(k,0,1,0,1))
allHashes[0]["ns"].append(2)
allHashes[0].append(canvas.getHash(k,0,0,1,1))
allHashes[0]["ns"].append(2)
allHashes[0].append(canvas.getHash(k,1,1,1,0))
allHashes[0]["ns"].append(3)
allHashes[0].append(canvas.getHash(k,1,0,1,1))
allHashes[0]["ns"].append(3)
allHashes[0].append(canvas.getHash(k,1,1,0,1))
allHashes[0]["ns"].append(3)
allHashes[0].append(canvas.getHash(k,0,1,1,1))
allHashes[0]["ns"].append(3)
allHashes[0].append(canvas.getHash(k,1,1,1,1))
allHashes[0]["ns"].append(4)
k += 1

while (k < head.k + 1):
    i = 0
    for hashes in list(itertools.permutations(allHashes[k-1]["hashes"])):
        hash = canvas.getHash(k,hashes[0], hashes[1], hashes[2], hashes[3])
        n = canvas.getHash(k,hashes[0], hashes[1], hashes[2], hashes[3])
        node = k,n,hash,hashes[0], hashes[1], hashes[2], hashes[3]
        allHashes[k].append(hash)


def main():
    pass