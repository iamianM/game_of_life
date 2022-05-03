from brownie import accounts, network, CanvasHashed, chain, config
import random
import json

LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["hardhat",
                                 "development", "ganache", "mainnet-fork"]

use_previous = False
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

canvas.create(4**4, {"from": accounts[0]})
print(canvas.print_head({"from": accounts[0]}))
# tx = canvas.activateNodes([[0,0], [0,3], [2,1], [3,0], [3,3]], {"from": accounts[0]})
tx = canvas.activateNodes([[0,0,1,2], [0,0,2,0], [0,0,2,3], [0,0,3,0], [0,0,3,2]], {"from": accounts[0]})
# tx = canvas.activateNodes([[0,0,0,3], [0,0,3,1], [0,0,2,3], [0,0,3,0], [0,0,3,2]], {"from": accounts[0]})
# tx = canvas.activateNodes([[0,0]], {"from": accounts[0]})
# tx = canvas.activateNodes([[0,3]], {"from": accounts[0]})
# tx = canvas.activateNodes([[2,1]], {"from": accounts[0]})
# tx = canvas.activateNodes([[3,0]], {"from": accounts[0]})
# tx = canvas.activateNodes([[3,3]], {"from": accounts[0]})
print(canvas.print_head({"from": accounts[0]}))
# tx.wait(5)
tx = canvas.advance_one({"from": accounts[0]})
print(canvas.print_head({"from": accounts[0]}))

# head = tuple(canvas.head({"from": accounts[0]}).dict().values())
# canvas.centre(head, {"from": accounts[0]})
# canvas.inner(head, {"from": accounts[0]})
# successor = canvas.successor(head, 0, {"from": accounts[0]})

# canvas.advance(head, 1, {"from": accounts[0]})
# print(canvas.print_head({"from": accounts[0]}))

# tx = canvas.advance_one({"from": accounts[0]})
# print(canvas.print_head({"from": accounts[0]}))
# tx.wait(8)
# tx = canvas.advance_one({"from": accounts[0]})
# print(canvas.print_head({"from": accounts[0]}))


def main():
    pass