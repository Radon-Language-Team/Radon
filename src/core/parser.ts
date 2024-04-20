/* eslint-disable quotes */
/**
 * RADON COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { Token, Nodes, validVariableTypes, validVariableTypesEnum } from '../interfaces/interfaces';
import { TokenType } from '../interfaces/interfaces';
import throwError from '../lib/errors/throwError';

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

      if (this.peek()?.type === TokenType.quit) {

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
          return throwError('Parser', `Token '${this.peek()?.type}' is unreachable -> Expected end of file or scope`, this.peek()!.line);
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
        
        const parsedVariable = parseVariable(this.tokens.slice(this.index));
        if (!parsedVariable.success) {
          return throwError('Parser', `Failed to parse variable declaration`, this.currentToken.line);
        }

        // TODO: Implement the logic for parsing the variable declaration so so we can remove code from this file
        // This way, we can keep the code clean and modular

        this.currentToken = this.consume();

        // This either happens if the identifier is not an alpha_numeric token or if the token is missing
        if (this.peek()?.type !== TokenType.alpha_numeric) {
          return throwError('Parser', `Expected identifier after 'var' keyword -> Can not be a number or a reserved keyword of Radon`, this.currentToken.line);
        }

        const identifier = this.consume();

        // Check if the identifier is already declared
        if (this.checkIfInitialized(identifier.value)) {
          return throwError('Parser', `Variable '${identifier.value}' has already been declared`, identifier.line);
        }

        if (this.peek()?.type !== TokenType.colon) {
          return throwError('Parser', `Expected ':' after identifier -> Variable type declaration is necessary in Radon`, this.currentToken.line);
        }

        this.currentToken = this.consume();

        if (this.peek()?.type !== TokenType.dollar_sign) {
          return throwError('Parser', `Expected '$' after ':' -> Variable type declaration is necessary in Radon`, this.currentToken.line);
        }

        this.currentToken = this.consume();

        if (validVariableTypes.includes(this.peek()?.value as string) === false) {
          return throwError('Parser', `Expected valid variable type after identifier '${identifier.value}'`, this.currentToken.line);
        }

        this.currentToken = this.consume();
        const declaredVariableType = this.currentToken.value;

        if (this.peek()?.type !== TokenType.equal) {
          return throwError('Parser', `Expected '=' after identifier`, this.currentToken.line);
        }

        this.currentToken = this.consume();
        let value: Token | undefined = undefined;

        // We need to check if the next token is a char/string or the next token after that is a char/string
        // That way, we can ignore the open_quote and close_quote tokens
        // Exmaple: var name: $string = 'Marwin';
        // Example: var name: $char = M;
        // In case of the second example, we need to throw an error because the open_quote is missing.
        if (this.peek()!.type === TokenType.quote) {

          this.currentToken = this.consume();
          value = this.consume();

        } else if (this.peek()!.type === TokenType.alpha_numeric) {

          // Check if the variable is initialized
          if (!this.checkIfInitialized(this.peek()?.value)) {
            return throwError('Parser', `Variable '${this.peek()?.value}' is not initialized`, this.peek()!.line);
          } else {
            value = this.peek();
            this.currentToken = this.consume();
          }

        } else {
          // Last token was not a variable nor a string/char -> It must be an int_literal or something that can be consumed right away
          value = this.consume();
        }

        if (!value) {
          return throwError('Parser', `Expected value after '=' in 'var' statement`, this.currentToken.line);
        }

        const givenValueType = this.returnVariableType(value.value) || validVariableTypesEnum[value.type as keyof typeof validVariableTypesEnum];

        if (declaredVariableType !== givenValueType) {
          throw new Error(`On line ${value.line} -> Expected value of type '${declaredVariableType}' but got '${givenValueType}'`);
        }

        // if the last token was of type string/char then we need to check if the next token is a close_quote
        if (value.type === TokenType.string || value.type === TokenType.char) {

          if (this.peek()?.type !== TokenType.quote) {
            return throwError('Parser', `Expected closing quote after ${value.type} value`, this.currentToken.line);
          }

          this.currentToken = this.consume();

        }

        const additionalExpressions: Token[] = [];

        if (this.peek()?.type === TokenType.plus) {

          while (this.peek()?.type === TokenType.plus) {

            this.currentToken = this.consume();
            let nextExpression = this.peek();

            if (!nextExpression) {
              return throwError('Parser', `Expected expression after '+' in 'var' statement`, this.currentToken.line);
            }

            if (this.peek()?.type === TokenType.quote) {

              this.currentToken = this.consume();
              nextExpression = this.consume();

            } else if (this.peek()?.type === TokenType.alpha_numeric) {

              // Could be a variable that is not initialized
              if (!this.checkIfInitialized(nextExpression.value)) {
                return throwError('Parser', `Variable '${nextExpression.value}' is not initialized`, nextExpression.line);
              } else {
                nextExpression = this.consume();
              }

            } else if (this.peek()?.type === TokenType.int_literal) {

              this.currentToken = this.consume();

            }

            if (nextExpression.type === TokenType.string || nextExpression.type === TokenType.char) {

              if (this.peek()?.type !== TokenType.quote) {
                return throwError('Parser', `Expected closing quote after ${value.type} value`, this.currentToken.line);
              }

              this.currentToken = this.consume();

            }

            const previousExpressionType = this.returnVariableType(value.value) ?? validVariableTypesEnum[value.type as keyof typeof validVariableTypesEnum];
            const nextExpressionType = this.returnVariableType(nextExpression.value) ?? validVariableTypesEnum[nextExpression.type as keyof typeof validVariableTypesEnum];

            if (previousExpressionType !== nextExpressionType) {
              return throwError('Parser', `Expected same types for addition & concatenation -> Got '${previousExpressionType}' and '${nextExpressionType}'`, this.currentToken.line);
            }

            additionalExpressions.push(nextExpression);

          }

        }

        if (this.peek()?.type !== TokenType.semi_colon) {
          return throwError('Parser', `Expected ';' after variable declaration`, this.currentToken.line);
        }

        this.currentToken = this.consume();

        this.parsedStatements.push({
          variableDeclaration: {
            token: TokenType._var,
            identifier: identifier,
            value: value,
            additionalExpressions: {
              tokens: additionalExpressions,
            },
          },
        });

      } else {
        return throwError('Parser', `Unexpected token '${this.currentToken.value}'`, this.currentToken.line);
      }

    }

    return this.parsedStatements;

  }

}