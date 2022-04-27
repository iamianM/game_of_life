from brownie import accounts, network, Canvas, chain, config
import random
import json

LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["hardhat",
                                 "development", "ganache", "mainnet-fork"]



def deploy_and_create(accounts, use_previous=None):
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
        canvas = Canvas.at(previous[cur_network]['canvas'])
    else:
        canvas = Canvas.deploy(
            {"from": account}, publish_source=publish_source)

    if cur_network not in previous:
        previous[cur_network] = {}
    previous[cur_network] = {
        'canvas': canvas.address
    }
    json.dump(previous, open('previous.json', 'w'))

    canvas.activateNodes([[0,0,0,0]], 
        {"from": accounts[0], "gas_limit": 10000000000})
    canvas.print_head({"from": accounts[0]})
    tx = canvas.advance_one({"from": accounts[0], "gas_limit": 10000000000, "allow_revert": False})
    tx.wait(8)
    tx = canvas.advance_one({"from": accounts[0], "gas_limit": 10000000000})
    
    # t = 4**canvas.kHead()
    # for i in range(4):
    #     for j in range(4):
    #         for l in range(4):
    #             for m in range(4):
    #                 temp = []
    #                 for n in range(4):
    #                     temp.append([i,j,l,m,n])
    #                 canvas.activateNodes(temp)

    # canvas.create(canvas.numCells())
    # for i in range(4):
    #     for j in range(4):
    #         for l in range(4):
    #             for m in range(4):
    #                 temp = []
    #                 for n in range(4):
    #                     temp.append([n,m,l,j,i])
    #                 canvas.activateNodes(temp)

    return canvas


def main(use_previous=None):
    deploy_and_create(accounts, use_previous)
