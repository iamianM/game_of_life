from brownie import accounts, network, CanvasCondensed, chain, config
import random
import json

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
    canvas = CanvasCondensed.at(previous[cur_network]['canvas'])
else:
    canvas = CanvasCondensed.deploy({"from": account})
        # {"from": account}, publish_source=publish_source)

if cur_network not in previous:
    previous[cur_network] = {}
previous[cur_network] = {
    'canvas': canvas.address
}
json.dump(previous, open('previous.json', 'w'))

for i in range(4):
    for j in range(4):
        for l in range(4):
            temp = []
            for n in range(4):
                temp.append([i,j,l])
            canvas.activateNodes(temp, {"from": accounts[0]})

canvas.create(canvas.numCells(), {"from": accounts[0]})
for i in range(4):
    for j in range(4):
        for l in range(4):
            temp = []
            for n in range(4):
                temp.append([l,j,i])
            canvas.activateNodes(temp, {"from": accounts[0]})