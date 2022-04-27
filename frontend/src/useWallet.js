import { useState } from "react";

export function useWallet() {
    const { ethereum } = window;
    const [currentAccount, setCurrentAccount] = useState(ethereum.selectedAddress);

    // @ts-ignore
    ethereum.on("accountsChanged", ([newAccount]) => {
        console.log("accountsChanged: ", newAccount);
        setCurrentAccount(newAccount);
    })

    return { currentAccount, setCurrentAccount};
}
