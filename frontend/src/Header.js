import React from "react";
import { Button, Nav, Navbar } from "react-bootstrap";
import Container from "react-bootstrap/Container";
import { style } from "./Header.styles";
import { Link } from "react-router-dom";

const Header = ({ currentAccount, setCurrentAccount }) => {
  const { ethereum } = window;

  const connectWallet = async () => {
    if (!ethereum) {
      console.log("No wallet plugin is available!");
      return;
    }

    try {
      const [account] = await ethereum.request({
        method: "eth_requestAccounts",
      });
      setCurrentAccount(account);
    } catch (err) {
      console.log(err);
    }
  };

  return (
    <Navbar bg="#ff1">
      {style}
      <Container>
        <Navbar.Brand>
          <Link to="/">Canvas</Link>
        </Navbar.Brand>
        <Nav className="me-auto">
          <Nav.Link>
            <Link to="/my-token">Your Token</Link>
          </Nav.Link>
          <Nav.Link>
            <Link to="/#faq">FAQ</Link>
          </Nav.Link>
        </Nav>
        <Nav>
          {!currentAccount && (
            <Button
              className="btn-rounded connect-button"
              variant="flat"
              onClick={() => connectWallet()}
            >
              Connect to wallet
            </Button>
          )}
          {currentAccount && (
            <Navbar.Text>
              Address: {currentAccount.slice(0, 5)}...
              {currentAccount.slice(currentAccount.length - 5)}
            </Navbar.Text>
          )}
        </Nav>
      </Container>
    </Navbar>
  );
};

export default Header;
