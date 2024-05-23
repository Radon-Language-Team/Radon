/* eslint-disable quotes */
/**
 * RADON COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { Token, Nodes, validVariableTypesEnum, TokenCategory } from '../interfaces/interfaces';
import { TokenType } from '../interfaces/interfaces';
import throwError from '../lib/errors/throwError';
import throwWarning from '../lib/errors/throwWarning';

import parseVariable from '../lib/parser/parseVariable';

export default class Parser {

  protected tokens: Token[];
  protected index: number;
  protected currentToken: Token;
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

  public returnVariableType(variableName: string | undefined): string | undefined {
    if (!variableName) {
      return undefined;
    }
    for (const statement of this.parsedStatements) {
      if (statement.variableDeclaration) {
        if (statement.variableDeclaration.identifier.value === variableName) {
          return validVariableTypesEnum[statement.variableDeclaration.value.type as keyof typeof validVariableTypesEnum];
        } else {
          continue;
        }
      } else {
        continue;
      }
    }
    return undefined;
  }

  public parse(): Nodes[] | undefined {

    const validExpressionType = ['int_literal', 'alpha_numeric'];

    while (this.peek()) {

      if (this.peek()?.category === TokenCategory.comment) {

        this.currentToken = this.consume();

        this.parsedStatements.push({
          singleLineComment: {
            token: this.currentToken.type,
            value: this.currentToken.value ?? '',
          },
        });

      } else if (this.peek()?.type === TokenType.quit) {

        this.currentToken = this.consume();

        if (this.peek()?.type !== TokenType.open_paren) {
          return throwError('Parser', `Expected '(' after 'quit' statement`, this.currentToken.line);
        }

        this.currentToken = this.consume();
        const expression = this.consume();

        if (!validExpressionType.includes(expression.type)) {
          return throwError('Parser', `Expected integer literal or identifier after '(' in 'quit' statement`, expression.line);
        }

        // Check if the variable is initialized -> Only alpha_numeric tokens can be uninitialized
        if (expression.type === TokenType.alpha_numeric) {
          if (!this.checkIfInitialized(expression.value)) {
            return throwError('Parser', `Variable '${expression.value}' is not initialized`, expression.line);
          }
        }

        if (this.peek()?.type !== TokenType.close_paren) {
          return throwError('Parser', `Expected ')' after integer literal in 'quit' statement`, this.currentToken.line);
        }

        this.currentToken = this.consume();

        if (this.peek()?.type !== TokenType.semi_colon) {
          return throwError('Parser', `Expected ';' after 'quit' statement`, this.currentToken.line);
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
          // We do not want to stop the parsing here, we just want to warn the user that there is unreachable code
          throwWarning('Parser', `Token '${this.peek()?.type}' is unreachable`, this.peek()!.line);
        }

      } else if (this.peek()?.type === TokenType.log) {

        this.currentToken = this.consume();

        if (this.peek()?.type !== TokenType.open_paren) {
          return throwError('Parser', `Expected '(' after 'log' statement`, this.currentToken.line);
        }

        this.currentToken = this.consume();
        const expression = this.consume();

        if (!validExpressionType.includes(expression.type)) {
          return throwError('Parser', `Expected integer literal or identifier after '(' in 'log' statement`, expression.line);
        }

        if (expression.type === TokenType.alpha_numeric) {
          if (!this.checkIfInitialized(expression.value)) {
            return throwError('Parser', `Variable '${expression.value}' is not initialized`, expression.line);
          }
        }

        const additionalExpressions: Token[] = [];

        if (this.peek()?.type === TokenType.plus) {

          while (this.peek()?.type === TokenType.plus) {

            this.currentToken = this.consume();
            const nextExpression = this.peek();

            if (!nextExpression) {
              throwError('Parser', `Expected expression after '+' in 'log' statement`, this.currentToken.line);
              return;
            }

            if (!validExpressionType.includes(nextExpression.type)) {
              return throwError('Parser', `Expected integer literal or identifier after '+' in 'log' statement`, nextExpression.line);
            }

            if (nextExpression.type === 'alpha_numeric') {
              if (!this.checkIfInitialized(nextExpression.value)) {
                return throwError('Parser', `Variable '${nextExpression.value}' is not initialized`, nextExpression.line);
              }
            }

            const previousExpressionType = this.returnVariableType(expression.value) ?? validVariableTypesEnum[expression.type as keyof typeof validVariableTypesEnum];
            const nextExpressionType = this.returnVariableType(nextExpression.value) ?? validVariableTypesEnum[nextExpression.type as keyof typeof validVariableTypesEnum];

            if (previousExpressionType !== nextExpressionType) {
              return throwError('Parser', `Expected same types for addition & concatenation -> Got '${previousExpressionType}' and '${nextExpressionType}'`, this.currentToken.line);
            }

            this.currentToken = this.consume();
            additionalExpressions.push(nextExpression);

          }

        }

        if (this.peek()?.type !== TokenType.close_paren) {
          return throwError('Parser', `Expected ')' after integer literal in 'log' statement`, this.currentToken.line);
        }

        this.currentToken = this.consume();

        if (this.peek()?.type !== TokenType.semi_colon) {
          return throwError('Parser', `Expected ';' after 'log' statement`, this.currentToken.line);
        }

        this.currentToken = this.consume();

        this.parsedStatements.push({
          logStatement: {
            token: TokenType.log,
            expression: {
              token: expression,
            },
            additionalExpressions: {
              tokens: additionalExpressions,
            },
          },
        });

      } else if (this.peek()?.type === TokenType._var) {

        // Pass in the tokens at the current index. So we can start where the 'var' keyword is
        const parsedVariable = parseVariable(this.tokens.slice(this.index), this.parsedStatements);

        if (!parsedVariable.success || !parsedVariable.node?.identifier || !parsedVariable.node.value) {
          return throwError('Parser', `Failed to parse variable declaration: ${parsedVariable.errorMessage}`, this.currentToken.line);
        }

        this.parsedStatements.push({
          variableDeclaration: {
            token: TokenType._var,
            identifier: parsedVariable.node?.identifier,
            value: parsedVariable.node?.value,
            additionalExpressions: parsedVariable.node.additionalExpressions,
          },
        });

        // Increment the index by the amount of tokens that were consumed so the parser can continue at the right position
        this.index += parsedVariable.consumedTokens;

      } else {
        return throwError('Parser', `Unexpected token '${this.currentToken.value}'`, this.currentToken.line);
      }

    }

    return this.parsedStatements;

  }

}