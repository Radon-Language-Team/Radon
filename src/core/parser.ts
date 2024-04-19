/**
 * RADON COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { Token, Nodes, validVariableTypes, validVariableTypesEnum } from '../interfaces/interfaces';
import { TokenType } from '../interfaces/interfaces';

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

      if (this.peek()?.type === 'quit') {

        this.currentToken = this.consume();

        if (this.peek()?.type !== TokenType.open_paren) {
          throw new Error(`On line ${this.currentToken.line} -> Expected '(' after 'quit' statement`);
        }

        this.currentToken = this.consume();
        const expression = this.consume();

        if (!validExpressionType.includes(expression.type)) {
          throw new Error(`On line ${expression.line} -> Expected integer literal or identifier after '(' in 'quit' statement`);
        }

        // Check if the variable is initialized -> Only alpha_numeric tokens can be uninitialized
        if (expression.type === 'alpha_numeric') {
          if (!this.checkIfInitialized(expression.value)) {
            throw new Error(`On line ${expression.line} -> Variable '${expression.value}' is not initialized`);
          }
        }

        if (this.peek()?.type !== TokenType.close_paren) {
          throw new Error(`On line ${this.currentToken.line} -> Expected ')' after integer literal in 'quit' statement`);
        }

        this.currentToken = this.consume();

        if (this.peek()?.type !== TokenType.semi_colon) {
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

        if (this.peek()?.type !== TokenType.open_paren) {
          throw new Error(`On line ${this.currentToken.line} -> Expected '(' after 'log' statement`);
        }

        this.currentToken = this.consume();
        const expression = this.consume();

        if (!validExpressionType.includes(expression.type)) {
          throw new Error(`On line ${expression.line} -> Expected integer literal or identifier after '(' in 'log' statement`);
        }

        if (expression.type === TokenType.alpha_numeric) {
          if (!this.checkIfInitialized(expression.value)) {
            throw new Error(`On line ${expression.line} -> Variable '${expression.value}' is not initialized`);
          }
        }

        const additionalExpressions: Token[] = [];

        if (this.peek()?.type === TokenType.plus) {

          while (this.peek()?.type === TokenType.plus) {

            this.currentToken = this.consume();
            const nextExpression = this.peek();

            if (!nextExpression) {
              throw new Error(`On line ${this.currentToken.line} -> Expected expression after '+' in 'log' statement`);
            }

            if (!validExpressionType.includes(nextExpression.type)) {
              throw new Error(`On line ${nextExpression.line} -> Expected integer literal or identifier after '+' in 'log' statement`);
            }

            if (nextExpression.type === 'alpha_numeric') {
              if (!this.checkIfInitialized(nextExpression.value)) {
                throw new Error(`On line ${nextExpression.line} -> Variable '${nextExpression.value}' is not initialized`);
              }
            }

            const previousExpressionType = this.returnVariableType(expression.value) ?? validVariableTypesEnum[expression.type as keyof typeof validVariableTypesEnum];
            const nextExpressionType = this.returnVariableType(nextExpression.value) ?? validVariableTypesEnum[nextExpression.type as keyof typeof validVariableTypesEnum];

            if (previousExpressionType !== nextExpressionType) {
              throw new Error(`On line ${this.currentToken.line} -> Expected same types for addition & concatenation -> Got '${previousExpressionType}' and '${nextExpressionType}'`);
            }

            this.currentToken = this.consume();
            additionalExpressions.push(nextExpression);

          }

        }

        if (this.peek()?.type !== TokenType.close_paren) {
          throw new Error(`On line ${this.currentToken.line} -> Expected ')' after integer literal in 'log' statement`);
        }

        this.currentToken = this.consume();

        if (this.peek()?.type !== TokenType.semi_colon) {
          throw new Error(`On line ${this.currentToken.line} -> Expected ';' after 'log' statement`);
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

        this.currentToken = this.consume();

        // This either happens if the identifier is not an alpha_numeric token or if the token is missing
        if (this.peek()?.type !== TokenType.alpha_numeric) {
          throw new Error(`On line ${this.currentToken.line} -> Expected identifier after 'var' keyword -> Can not be a number or a reserved keyword of Radon`);
        }

        const identifier = this.consume();

        // Check if the identifier is already declared
        if (this.checkIfInitialized(identifier.value)) {
          throw new Error(`On line ${identifier.line} -> Variable '${identifier.value}' has already been declared`);
        }

        if (this.peek()?.type !== TokenType.colon) {
          throw new Error(`On line ${this.currentToken.line} -> Expected ':' after identifier -> Variable type declaration is necessary in Radon`);
        }

        this.currentToken = this.consume();

        if (this.peek()?.type !== TokenType.dollar_sign) {
          throw new Error(`On line ${this.currentToken.line} -> Expected '$' after ':' -> Variable type declaration is necessary in Radon`);
        }

        this.currentToken = this.consume();

        if (validVariableTypes.includes(this.peek()?.value as string) === false) {
          throw new Error(`On line ${this.currentToken.line} -> Expected valid variable type after identifier ${identifier.value}`);
        }

        this.currentToken = this.consume();
        const declaredVariableType = this.currentToken.value;

        if (this.peek()?.type !== TokenType.equal) {
          throw new Error(`On line ${this.currentToken.line} -> Expected '=' after identifier`);
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
            throw new Error(`On line ${this.peek()?.line} -> Variable '${this.peek()?.value}' is not initialized`);
          } else {
            value = this.peek();
            this.currentToken = this.consume();
          }

        } else {
          // Last token was not a variable nor a string/char -> It must be an int_literal or something that can be consumed right away
          value = this.consume();
        }

        if (!value) {
          throw new Error(`On line ${this.currentToken.line} -> Expected value after '=' in 'var' statement`);
        }

        const givenValueType = this.returnVariableType(value.value) || validVariableTypesEnum[value.type as keyof typeof validVariableTypesEnum];

        if (declaredVariableType !== givenValueType) {
          throw new Error(`On line ${value.line} -> Expected value of type '${declaredVariableType}' but got '${givenValueType}'`);
        }

        // if the last token was of type string/char then we need to check if the next token is a close_quote
        if (value.type === TokenType.string || value.type === TokenType.char) {

          if (this.peek()?.type !== TokenType.quote) {
            throw new Error(`On line ${this.currentToken.line} -> Expected closing quote after ${value.type} value`);
          }

          this.currentToken = this.consume();

        }

        const additionalExpressions: Token[] = [];

        if (this.peek()?.type === TokenType.plus) {

          while (this.peek()?.type === TokenType.plus) {

            this.currentToken = this.consume();
            let nextExpression = this.peek();

            if (!nextExpression) {
              throw new Error(`On line ${this.currentToken.line} -> Expected expression after '+' in 'var' statement`);
            }

            if (this.peek()?.type === TokenType.quote) {

              this.currentToken = this.consume();
              nextExpression = this.consume();

            } else if (this.peek()?.type === TokenType.alpha_numeric) {

              // Could be a variable that is not initialized
              if (!this.checkIfInitialized(nextExpression.value)) {
                throw new Error(`On line ${nextExpression.line} -> Variable '${nextExpression.value}' is not initialized`);
              } else {
                nextExpression = this.consume();
              }

            } else if (this.peek()?.type === TokenType.int_literal) {

              this.currentToken = this.consume();

            }

            if (nextExpression.type === TokenType.string || nextExpression.type === TokenType.char) {

              if (this.peek()?.type !== TokenType.quote) {
                throw new Error(`On line ${this.currentToken.line} -> Expected closing quote after ${value.type} value`);
              }

              this.currentToken = this.consume();

            }

            const previousExpressionType = this.returnVariableType(value.value) ?? validVariableTypesEnum[value.type as keyof typeof validVariableTypesEnum];
            const nextExpressionType = this.returnVariableType(nextExpression.value) ?? validVariableTypesEnum[nextExpression.type as keyof typeof validVariableTypesEnum];

            if (previousExpressionType !== nextExpressionType) {
              throw new Error(`On line ${this.currentToken.line} -> Expected same types for addition & concatenation -> Got '${previousExpressionType}' and '${nextExpressionType}'`);
            }

            additionalExpressions.push(nextExpression);

          }

        }

        if (this.peek()?.type !== TokenType.semi_colon) {
          throw new Error(`On line ${this.currentToken.line} -> Expected ';' after variable declaration`);
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
        throw new Error(`Unexpected token '${this.currentToken.value}' on line ${this.currentToken.line}`);
      }

    }

    return this.parsedStatements;

  }

}

export default Parser;