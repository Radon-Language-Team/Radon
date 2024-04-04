/**
 * RADIUM COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { Token, Nodes } from './interfaces/interfaces';
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

  public checkIfInitialized(variableName: string | undefined): boolean {
    if (!variableName) {
      return false;
    }
    for (const statement of this.parsedStatements) {
      if (statement.variableDeclaration) {
        if (statement.variableDeclaration.identifier.value === variableName) {
          return true;
        } else {
          continue;
        }
      } else {
        continue;
      }
    }
    return false;
  }

  public parse(): Nodes[] | undefined {

    const validExpressionType = ['int_literal', 'alpha_numeric'];

    while (this.peek()) {

      if (this.peek()?.type === 'quit') {

        this.currentToken = this.consume();

        if (this.peek()?.type !== 'open_paren') {
          throw new Error(`On line ${this.currentToken.line} -> Expected '(' after 'quit' statement`);
        }

        this.currentToken = this.consume();
        const expression = this.consume();

        if (!validExpressionType.includes(expression.type)) {
          throw new Error(`On line ${expression.line} -> Expected integer literal or variable name after '(' in 'quit' statement`);
        }

        // Check if the variable is initialized -> Only alpha_numeric tokens can be uninitialized
        if (expression.type === 'alpha_numeric') {
          if (!this.checkIfInitialized(expression.value)) {
            throw new Error(`On line ${expression.line} -> Variable '${expression.value}' is not initialized`);
          }
        }

        if (this.peek()?.type !== 'close_paren') {
          throw new Error(`On line ${this.currentToken.line} -> Expected ')' after integer literal in 'quit' statement`);
        }

        this.currentToken = this.consume();

        if (this.peek()?.type !== 'semi_colon') {
          throw new Error(`On line ${this.currentToken.line} -> Expected ';' after 'quit' statement`);
        }

        this.currentToken = this.consume();

        this.parsedStatements.push({
          quitStatement: {
            token: TokenType.quit,
            expression: {
              token: expression,
            },
          },
        });

        if (this.peek()) {
          throw new Error(`Token '${this.peek()?.type}' on line ${this.peek()?.line} is unreachable -> Expected end of file or scope`);
        }

      } else if (this.peek()?.type === 'log') {

        this.currentToken = this.consume();

        if (this.peek()?.type !== 'open_paren') {
          throw new Error(`On line ${this.currentToken.line} -> Expected '(' after 'log' statement`);
        }

        this.currentToken = this.consume();
        const expression = this.consume();

        if (!validExpressionType.includes(expression.type)) {
          throw new Error(`On line ${expression.line} -> Expected integer literal or variable name after '(' in 'log' statement`);
        }

        if (expression.type === 'alpha_numeric') {
          if (!this.checkIfInitialized(expression.value)) {
            throw new Error(`On line ${expression.line} -> Variable '${expression.value}' is not initialized`);
          }
        }

        if (this.peek()?.type !== 'close_paren') {
          throw new Error(`On line ${this.currentToken.line} -> Expected ')' after integer literal in 'log' statement`);
        }

        this.currentToken = this.consume();

        if (this.peek()?.type !== 'semi_colon') {
          throw new Error(`On line ${this.currentToken.line} -> Expected ';' after 'log' statement`);
        }

        this.currentToken = this.consume();

        this.parsedStatements.push({
          logStatement: {
            token: TokenType.log,
            expression: {
              token: expression,
            },
          },
        });

      } else if (this.peek()?.type === 'var') {

        this.currentToken = this.consume();

        // This either happens if the variable name is not an alpha_numeric token or if the token is missing
        if (this.peek()?.type !== 'alpha_numeric') {
          throw new Error(`On line ${this.currentToken.line} -> Expected variable name after 'var' keyword -> Can not be a number or a reserved keyword of Radium`);
        }

        const identifier = this.consume();

        if (this.peek()?.type !== 'equal') {
          throw new Error(`On line ${this.currentToken.line} -> Expected '=' after variable name`);
        }

        this.currentToken = this.consume();
        const value = this.consume();

        if (this.currentToken.type !== 'int_literal') {
          throw new Error(`On line ${this.currentToken.line} -> Expected integer literal after '=' -> For now, only integer literals are supported`);
        }

        if (this.peek()?.type !== 'semi_colon') {
          throw new Error(`On line ${this.currentToken.line} -> Expected ';' after integer literal`);
        }

        this.currentToken = this.consume();

        this.parsedStatements.push({
          variableDeclaration: {
            token: TokenType._var,
            identifier: identifier,
            value: value,
          },
        });

      } else {
        throw new Error(`Unexpected token '${this.currentToken.value}' on line ${this.currentToken.line}`);
      }

    }

    return this.parsedStatements;

  }

}

export default Parser;