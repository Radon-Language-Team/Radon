/**
 * RADON COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { Token, Nodes, validVariableTypes, validVariableTypesEnum } from '../interfaces/interfaces';
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

        const additionalExpressions: Token[] = [];

        if (this.peek()?.type === 'plus') {
          this.currentToken = this.consume();

          // The reason we do this is because the expression might not be a variable at all as it could just be a number or a string
          // In this case, we simply take the token type provided by the tokenizer
          const previousExpressionType = this.returnVariableType(expression.value) ?? validVariableTypesEnum[expression.type as keyof typeof validVariableTypesEnum];
          const nextExpression = this.peek();
          const nextExpressionType = this.returnVariableType(nextExpression?.value) ?? validVariableTypesEnum[nextExpression?.type as keyof typeof validVariableTypesEnum];

          // We know that the previous expression is initialized because we checked it above
          // We now need to check if the next expression is initialized
          if (nextExpression?.type === 'alpha_numeric') {
            if (!this.checkIfInitialized(nextExpression.value)) {
              throw new Error(`On line ${nextExpression.line} -> Variable '${nextExpression.value}' is not initialized`);
            }
          }

          // Check if the types are the same. Since we compile to JS, JS will handle the addition of strings and numbers
          // We just need to validate the types / syntax
          if (previousExpressionType !== nextExpressionType) {
            throw new Error(`On line ${this.currentToken.line} -> Expected same types for addition & concatenation -> Got '${previousExpressionType}' and '${nextExpressionType}'`);
          }

          this.currentToken = this.consume();
          // This only works for ONE additional expression for now
          additionalExpressions.push(this.currentToken);
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
            additionalExpressions: {
              tokens: additionalExpressions,
            },
          },
        });

      } else if (this.peek()?.type === 'var') {

        this.currentToken = this.consume();

        // This either happens if the variable name is not an alpha_numeric token or if the token is missing
        if (this.peek()?.type !== 'alpha_numeric') {
          throw new Error(`On line ${this.currentToken.line} -> Expected variable name after 'var' keyword -> Can not be a number or a reserved keyword of Radon`);
        }

        const identifier = this.consume();

        if (this.peek()?.type !== 'colon') {
          throw new Error(`On line ${this.currentToken.line} -> Expected ':' after variable name -> Variable type declaration is necessary in Radon`);
        }

        this.currentToken = this.consume();

        if (this.peek()?.type !== 'dollar_sign') {
          throw new Error(`On line ${this.currentToken.line} -> Expected '$' after ':' -> Variable type declaration is necessary in Radon`);
        }

        this.currentToken = this.consume();

        if (validVariableTypes.includes(this.peek()?.value as string) === false) {
          throw new Error(`On line ${this.currentToken.line} -> Expected valid variable type after identifier ${identifier.value}`);
        }

        this.currentToken = this.consume();
        const declaredVariableType = this.currentToken.value;

        if (this.peek()?.type !== 'equal') {
          throw new Error(`On line ${this.currentToken.line} -> Expected '=' after variable name`);
        }

        this.currentToken = this.consume();

        // We need to check if the next token is a char/string or the next token after that is a char/string
        // That way, we can ignore the open_quote and close_quote tokens
        // Exmaple: var name: $string = 'Marwin';
        // Example: var name: $char = M;
        // In case of the second example, we need to throw an error because the open_quote is missing.
        if (this.peek()!.type === 'open_quote') {

          this.currentToken = this.consume();

        } else if (this.peek()!.type === 'alpha_numeric') {

          // The next token after the = is an alpha numeric token but the open_quote is missing
          throw new Error(`On line ${this.currentToken.line} -> Provided alpha_numeric token '${this.peek()?.value}' but the open_quote is missing`);

        }

        const value = this.consume();
        const givenValueType = validVariableTypesEnum[value.type as keyof typeof validVariableTypesEnum];

        if (declaredVariableType !== givenValueType) {
          throw new Error(`On line ${value.line} -> Expected value of type '${declaredVariableType}' but got '${givenValueType}'`);
        }

        // if the last token was of type string/char then we need to check if the next token is a close_quote
        if (value.type === 'string' || value.type === 'char') {

          if (this.peek()?.type !== 'close_quote') {
            throw new Error(`On line ${this.currentToken.line} -> Expected closing quote after ${value.type} value`);
          }

          this.currentToken = this.consume();

        }

        if (this.peek()?.type !== 'semi_colon') {
          throw new Error(`On line ${this.currentToken.line} -> Expected ';' after variable declaration`);
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