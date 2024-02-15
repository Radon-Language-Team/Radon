/**
 * RADIUM COMPILER
 *
 * Copyright (C) 2024 - Marwin Eder
*/

import { Token, NodeExpression, NodeQuitStatement } from './interfaces/interfaces';
import { TokenType } from './tokenization';

class Parser {

  private tokens: Token[];
  private index: number;
  private currentToken: Token;

  constructor(tokens: Token[]) {
    this.tokens = [...tokens];
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

  public parse(): NodeQuitStatement | undefined {

    while (this.peek()) {

      if (this.peek()?.type === 'quit') {

        this.currentToken = this.consume();

        if (this.peek()?.type !== 'open_paren') {
          throw new Error('Expected `(` after `quit` statement');
        }

        this.currentToken = this.consume();
        const expression = this.consume();

        if (expression.type !== 'int_literal') {
          throw new Error('Expected integer literal');
        }

        if (this.peek()?.type !== 'close_paren') {
          throw new Error('Expected `)` after expression in `quit` statement');
        }

        this.currentToken = this.consume();

        if (this.peek()?.type !== 'semi_colon') {
          throw new Error('Expected `;` after `quit` statement');
        }

        this.currentToken = this.consume();

        return {
          token: TokenType.quit,
          expression: {
            token: expression,
          },
        };

      } else {
        throw new Error('Unexpected token');
      }

    }

  }

}

export default Parser;