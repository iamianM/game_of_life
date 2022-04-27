import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";

import "bootstrap/dist/css/bootstrap.min.css";

// Components
import Home from "./Home";
import Header from "./Header";
import { useWallet } from "./useWallet";

function App() {
  const { currentAccount, setCurrentAccount } = useWallet();
  return (
    <Router>
      <Header
        currentAccount={currentAccount}
        setCurrentAccount={setCurrentAccount}
      />
      <Home currentAccount={currentAccount} />
    </Router>
  );
}

export default App;
