/**
 * RADIUM COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

class TestInput {

  private input: string;

  constructor(input: string) {
    this.input = input;
  }

  public isAlnum(): boolean {
    if (this.input) {
      if (this.input.match(/^[a-zA-Z]+$/)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  public isInt(): boolean {
    if (this.input) {
      if (this.input.toString().match(/^[0-9]+$/)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  public isParenthesis(): boolean {
    if (this.input) {
      if (this.input.match(/^[()]+$/)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  public isOperator(): boolean {
    if (this.input) {
      if (this.input.match(/^[=+\-*/]+$/)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

}

const testInput = new TestInput('=');
console.log('isAlnum', testInput.isAlnum());
console.log('isInt', testInput.isInt());
console.log('isParenthesis', testInput.isParenthesis());
console.log('isOperator', testInput.isOperator());
