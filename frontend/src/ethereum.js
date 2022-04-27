import Web3 from "web3";
import Canvas from "./build/contracts/Canvas.json";
import { useState, useEffect } from "react";
import map from "./build/deployments/map.json";
// const REACT_APP_CANVAS_ADDRESS = map["Canvas"];
const REACT_APP_CANVAS_ADDRESS = "0x999f1A78c3f0939FEC7d796e647446E247633866";

const web3 = new Web3(window.ethereum);
window.ethereum.enable();

// const networkId = await web3.eth.net.getId();
// const deployedNetwork = Canvas.networks[networkId];
// const contractAddress = process.env.REACT_APP_CANVAS_ADDRESS;
const contractAddress = REACT_APP_CANVAS_ADDRESS;
const contract = new web3.eth.Contract(Canvas.abi, contractAddress);

export async function checkMintEvent() {
  Canvas.events
    .plotMinted({})
    .on("data", async function (event) {
      console.log(event.returnValues);
      // Do something here
    })
    .on("error", console.error);
}

export const getBalance = async (address) => {
  let balance = await web3.eth.getBalance(address);
  return web3.utils.fromWei(balance, "ether");
};

export function Count() {
  const [value, setValue] = useState(); // state variable to set account.

  useEffect(() => {
    async function load() {
      const value = await contract.methods.numCells().call();
      setValue(value);
    }

    load();
  }, []);

  return value;
}

export function Plots() {
  const [value, setValue] = useState(); // state variable to set account.

  useEffect(() => {
    async function load() {
      const value = await contract.methods.print_head().call();
      setValue(value);
    }

    load();
  }, []);

  return value;
}

export const activateNodes = async (nodes) => {
  const { ethereum } = window;
  const gasLimit = await contract.methods
    .activateNodes(nodes)
    .estimateGas({ from: ethereum.selectedAddress });
  const gasPrice = web3.eth.gasPrice;
  console.log(gasLimit, gasPrice);
  const transactionParams = {
    to: contractAddress,
    from: ethereum.selectedAddress,
    value: web3.utils.toHex(web3.utils.toWei("0.0", "ether")),
    gasLimit: gasLimit,
    gasPrice: gasPrice,
    data: contract.methods.activateNodes(nodes).encodeABI(),
  };
  return await ethereum.request({
    method: "eth_sendTransaction",
    params: [transactionParams],
  });
};

export const getToken = async (address) => {
  return await contract.methods.walletOfOwner(address).call();
};

export const getTokenUri = async (tokenId) => {
  return await contract.methods.tokenURI(tokenId).call();
};
