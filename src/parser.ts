/**
 * RADIUM COMPILER PARSER
 *
 * Radium is my own programming language. This file contains the parser
 * Copyright (C) 2024 - Marwin Eder
 */

import { Token, NodeExpression, NodeReturnStatement } from './interfaces/interfaces';

class Parser {

  private tokens: Token[];
  private index: number;
  private currentToken: Token;

  constructor(tokens: Token[]) {
    this.tokens = tokens;
    this.index = 0;
    this.currentToken = this.tokens[this.index];
  }

  public peek(offset: number = 0): Token | undefined {
    if (this.index + offset >= this.tokens.length) {
      return undefined;
    }
    return this.tokens[this.index + offset];
  }

  public consume(): Token {
    return this.currentToken = this.tokens[this.index++];
  }

  public parseExpression(): NodeExpression {
    return {
      token: this.currentToken,
    };
  }

  public parse(): NodeReturnStatement | undefined {

    while (this.peek()) {

      if (this.peek()?.type === 'return') {
        this.consume();
      }

      if (this.currentToken.type === 'return') {
        const expression = this.parseExpression();
        return {
          token: this.currentToken.type,
          expression,
        };
      } else {
        throw new Error('Unexpected token');
      }

    }

  }

}

export default Parser;