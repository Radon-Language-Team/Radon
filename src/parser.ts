/**
 * RADIUM COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { Token, NodeExpression, Nodes } from './interfaces/interfaces';
import { TokenType } from './tokenization';

class Parser {

  private tokens: Token[];
  private index: number;
  private currentToken: Token;
  private parsedStatements: Nodes[] = [];

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

  public parse(): Nodes[] | undefined {

    while (this.peek()) {

      if (this.peek()?.type === 'quit') {

        this.currentToken = this.consume();

        if (this.peek()?.type !== 'open_paren') {
          throw new Error(`On line ${this.currentToken.line}, expected '(' after 'quit' statement`);
        }

        this.currentToken = this.consume();
        const expression = this.consume();

        if (expression.type !== 'int_literal') {
          throw new Error(`On line ${expression.line}, expected integer literal after '(' in 'quit' statement`);
        }

        if (this.peek()?.type !== 'close_paren') {
          throw new Error(`On line ${this.currentToken.line}, expected ')' after integer literal in 'quit' statement`);
        }

        this.currentToken = this.consume();

        if (this.peek()?.type !== 'semi_colon') {
          throw new Error(`On line ${this.currentToken.line}, expected ';' after 'quit' statement`);
        }

        this.currentToken = this.consume();

        this.parsedStatements.push({
          quitStatement: {
            token: TokenType.quit,
            expression: this.parseExpression(),
          },
        });

      } else {
        throw new Error('Unexpected token');
      }

    }

    return this.parsedStatements;

  }

}

export default Parser;