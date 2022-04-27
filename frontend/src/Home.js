import React from "react";
import { Count, Plots } from "./ethereum";
import { createPortal } from "react-dom";
import { PhotoshopPicker } from "react-color";

function Square(props) {
  console.log(props);
  return (
    <button
      className="square"
      onClick={props.onClick}
      style={{
        backgroundColor: props.value,
        width: "100px",
        height: "100px",
        padding: 0,
        border: 0,
      }}
    ></button>
  );
}

class Board extends React.Component {
  renderSquare(i, j) {
    return (
      <Square
        key={i + "," + j}
        value={this.props.squares[i][j]}
        onClick={() => this.props.onClick(i, j)}
      />
    );
  }

  renderPlot(i, j, value) {
    return (
      <div
        class="square"
        key={i + "," + j}
        style={{
          backgroundColor: `rgb(${value.r}, ${value.g}, ${value.b})`,
          width: "100px",
          height: "100px",
          padding: 0,
          display: "inline-block",
        }}
      ></div>
    );
  }

  render() {
    return (
      <div>
        {this.props.squares.map((items, index) => {
          return (
            <div
              className="board-row"
              key={index}
              style={{
                height: "100px",
              }}
            >
              {items.map((subItems, sIndex) => {
                return subItems
                  ? this.renderPlot(index, sIndex, subItems)
                  : this.renderSquare(index, sIndex);
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
      plots: this.props.plots,
      plotCount: this.props.plotCount,
      squares: Array(this.props.nrows)
        .fill(null)
        .map((row) => new Array(this.props.nrows).fill(null)),
      showDialog: false,
    };
  }

  // async mintNFT() {
  //   const offset = (this.state.nrows - 1) / 2;
  //   console.log(
  //     this.state.picker.color,
  //     this.state.picker.i - offset,
  //     this.state.picker.j - offset
  //   );
  //   return await buyNFT(
  //     this.state.picker.color,
  //     this.state.picker.i - offset,
  //     this.state.picker.j - offset
  //   );
  // }

  // handleAccept = () => {
  //   this.state.showDialog = false;

  //   const r = this.mintNFT();
  //   console.log(r);
  //   this.state.squares[this.state.picker.i][this.state.picker.j] =
  //     this.state.picker.color;
  //   this.forceUpdate();
  // };

  handleClick(i, j) {
    const squares = this.state.squares.slice();
    console.log(squares[i][j]);
    if (squares[i][j]) {
      return;
    }

    this.state.picker.i = i;
    this.state.picker.j = j;
    this.state.showDialog = !this.state.showDialog;
    this.forceUpdate();
  }

  handleChangePicker = (color, event) => {
    this.setState({
      picker: {
        color: color.rgb,
        i: this.state.picker.i,
        j: this.state.picker.j,
      },
    });
  };

  getXandY = (k, x, y) => {
    if (k == 0) {
      return "(".concat(x.toString(), ",", y.toString(), ")");
    }
    var result = "";
    while (k != 0) {
      k--;
      result.concat(
        this.getXandY(k, x - 1, y - 1),
        ";",
        this.getXandY(k, x + 1, y - 1),
        ";",
        this.getXandY(k, x - 1, y + 1),
        ";",
        this.getXandY(k, x + 1, y + 1)
      );
      return result;
    }
  };

  render() {
    var { picker, nrows, plots, plotCount, squares, showDialog } = this.state;
    const k = 0;
    const n = plotCount;
    while (n > 1) {
      n = n >> 1;
      k++;
    }

    var points = this.getXandY(k, nrows, nrows);
    points = points.split(";");

    for (var ii = 0; ii < plotCount / 4; ii++) {
      for (var jj = 0; jj < 4; jj++) {
        const value = plots[ii * 4 + jj];
        const x_pos = parseInt(points[ii * 4 + jj][1]);
        const y_pos = parseInt(points[ii * 4 + jj][3]);
        console.log(value, x_pos, y_pos);

        if (value == "O") {
          this.state.squares[x_pos][y_pos] = {
            r: 255,
            g: 255,
            b: 255,
          };
        } else {
          this.state.squares[x_pos][y_pos] = {
            r: 0,
            g: 0,
            b: 0,
          };
        }
        if (picker.i) {
          console.log(picker.i, picker.j, picker.color);
          this.state.squares[picker.i][picker.j] = picker.color;
        }
      }
    }

    return (
      <div className="container">
        <div className="game">
          <div className="game-board">
            <Board
              squares={this.state.squares}
              onClick={(i, j) => this.handleClick(i, j)}
            />
          </div>
        </div>

        {showDialog === true ? (
          <DialogModal>
            <div className="dialog-wrapper">
              <i
                onClick={(e) => {
                  this.state.showDialog = false;
                }}
                className="fa fa-close btn-close"
              />
              <PhotoshopPicker
                disableAlpha={true}
                color={this.state.picker.color}
                onChange={this.handleChangePicker}
                // onAccept={this.handleAccept}
                onCancel={this.handleCancel}
                style={{
                  width: "100px",
                  height: "100px",
                  padding: 0,
                  border: 0,
                }}
              />
            </div>
          </DialogModal>
        ) : null}
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

  if (nrows !== 1 && plots.length === 0) {
    return "";
  }

  console.log("rows: " + nrows);
  console.log("count: ", plotCount);
  console.log(plots);

  return <Game nrows={nrows} plots={plots} plotCount={plotCount} />;
}

export default Home;
