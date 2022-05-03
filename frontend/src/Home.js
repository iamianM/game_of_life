import React from "react";
import {
  Count,
  Plots,
  activateNodes,
  updateHead,
  create,
  advanceOne,
} from "./ethereum";
import { createPortal } from "react-dom";

class Board extends React.Component {
  renderSquare(i, j) {
    const value = this.props.squares[i][j];
    return (
      <button
        className="square"
        key={i + "," + j}
        onClick={() => this.props.onClick(i, j)}
        style={{
          backgroundColor: `rgb(${value.r}, ${value.g}, ${value.b})`,
          width: "30px",
          height: "30px",
          padding: 0,
          border: "3px",
          borderStyle: value["border"],
          display: "inline-block",
        }}
      ></button>
    );
  }

  // renderPlot(i, j, value) {
  //   return (
  //     <div
  //       class="square"
  //       key={i + "," + j}
  //       style={{
  //         backgroundColor: `rgb(${value.r}, ${value.g}, ${value.b})`,
  //         width: "100px",
  //         height: "100px",
  //         padding: 0,
  //         display: "inline-block",
  //       }}
  //     ></div>
  //   );
  // }

  render() {
    return (
      <div>
        {this.props.squares.map((items, index) => {
          return (
            <div
              className="board-row"
              key={index}
              style={{
                height: "30px",
              }}
            >
              {items.map((subItems, sIndex) => {
                return this.renderSquare(sIndex, index);
              })}
            </div>
          );
        })}
      </div>
    );
  }
}

class Game extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      picker: { color: { r: 128, g: 128, b: 128 }, i: null, j: null },
      nrows: this.props.nrows,
      plots: this.props.plots.split(";"),
      plotCount: this.props.plotCount,
      squares: Array(this.props.nrows)
        .fill(null)
        .map((row) => new Array(this.props.nrows).fill(null)),
      showDialog: false,
      squaresClicked: Array(),
    };
    this.state.plots.pop();
  }

  async activate() {
    var nodes = [];
    // for (var i = 0; i < this.state.squaresClicked.length; i++) {
    //   nodes = Array.from(this.state.squaresClicked[i]);
    // }
    console.log(this.state.squaresClicked);
    return await activateNodes(this.state.squaresClicked);
  }

  async update() {
    return await updateHead();
  }

  async reset() {
    return await create(4 ** 3);
  }

  async advance() {
    return await advanceOne();
  }

  onClick(i, j) {
    const p = this.state.squares[i][j]["pos"];
    const index = this.state.squaresClicked.indexOf(p);
    if (index > -1) {
      this.state.squaresClicked.splice(index, 1);
      this.state.squares[i][j]["border"] = "none";
    } else {
      this.state.squaresClicked.push(p);
      this.state.squares[i][j]["border"] = "solid";
    }
    console.log(this.state.squaresClicked);
    this.forceUpdate();
  }

  render() {
    var { picker, nrows, plots, plotCount, squares, showDialog } = this.state;
    var k = 0;
    var n = plotCount;
    while (n > 1) {
      n = n / 4;
      k++;
    }

    var x_pos = 0;
    var y_pos = 0;
    var node = Array(k).fill(0);
    for (var i = 0; i < plotCount; i++) {
      var plot = plots[i];
      var nodeStr = plot.split("--")[0];
      var node = [];
      for (var j = 1; j < nodeStr.length; j++) {
        node.push(parseInt(nodeStr.charAt(j)));
      }
      const x_pos = plot.split("--")[1].split(":")[0].split(",")[0];
      const y_pos = plot.split("--")[1].split(":")[0].split(",")[1];
      const value = plot.split(":")[1];

      console.log(i, x_pos, y_pos, value, node, nodeStr);

      if (value == "X") {
        this.state.squares[x_pos][y_pos] = {
          pos: i,
          node: node,
          border: this.state.squaresClicked.indexOf(i) != -1 ? "solid" : "none",
          r: 0,
          g: 255,
          b: 0,
        };
      } else {
        this.state.squares[x_pos][y_pos] = {
          pos: i,
          node: node,
          border: this.state.squaresClicked.indexOf(i) != -1 ? "solid" : "none",
          r: 128,
          g: 128,
          b: 128,
        };
      }
    }

    return (
      <div className="container">
        <div className="game">
          <div className="game-board">
            <Board
              squares={this.state.squares}
              onClick={(i, j) => this.onClick(i, j)}
            />
          </div>
        </div>

        <button onClick={(i, j) => this.activate(i, j)}>Activate</button>
        <button onClick={(i, j) => this.update()}>Update</button>
        <button onClick={(i, j) => this.reset()}>Reset</button>
        <button onClick={(i, j) => this.advance()}>Advance</button>
      </div>
    );
  }
}

class DialogModal extends React.Component {
  constructor() {
    super();
    this.body = document.getElementsByTagName("body")[0];
    this.el = document.createElement("div");
    this.el.id = "dialog-root";
  }

  componentDidMount() {
    this.body.appendChild(this.el);
  }

  componentWillUnmount() {
    this.body.removeChild(this.el);
  }

  render() {
    return createPortal(this.props.children, this.el);
  }
}

function Home(currentAccount) {
  console.log(currentAccount);
  const plotCount = Count();
  const plots = Plots();
  const nrows = Math.sqrt(plotCount);

  if (!nrows || !plots || plots.length === 0) {
    return "";
  }

  console.log("rows: " + nrows);
  console.log("count: ", plotCount);
  console.log(plots);

  return <Game nrows={nrows} plots={plots} plotCount={plotCount} />;
}

export default Home;
