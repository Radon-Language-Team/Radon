/* eslint-disable no-shadow */
/**
 * RADON COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { TokenType } from '../core/tokenization';

export const validVariableTypes = ['int', 'string', 'char'];

export enum validVariableTypesEnum {
  int_literal = 'int',
  alpha_numeric = 'alpha_numeric',
  string = 'string',
  char = 'char'
}

export enum TokensCategory {
  // This is a string, like "Hello, World!"
  string = 'string',
  // This is a char, a single character like 'a'
  char = 'char',
  // This is a number, like 10
  int_literal = 'int',
  // This is a variable, like ... = 10
  variable = 'variable',
  // An expression is a combination of variables, strings, and numbers. Like the plus sign or the equal sign
  expression = 'expression',
  // This is an identifier, like a variable name
  identifier = 'identifier',
  // This is a keyword, like quit or log
  keyword = 'keyword',
}

export interface Token {
  type: TokenType;
  category : TokensCategory;
  line: number;
  value?: string;
}

export interface AdditionalTokens {
  tokens: Token[];
}

export interface NodeExpression {
  token: Token;
}

export interface NodeQuitStatement {
  token: TokenType;
  expression: NodeExpression;
}

export interface NodeLogStatement {
  token: TokenType;
  expression: NodeExpression;
  additionalExpressions?: AdditionalTokens;
}

export interface NodeVariableDeclaration {
  token: TokenType;
  identifier: Token;
  value: Token;
  additionalExpressions?: AdditionalTokens;
}

export interface Nodes {
  quitStatement?: NodeQuitStatement;
  logStatement?: NodeLogStatement;
  variableDeclaration?: NodeVariableDeclaration;
}