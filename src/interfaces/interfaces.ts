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

export interface Token {
  type: TokenType;
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
}

export interface Nodes {
  quitStatement?: NodeQuitStatement;
  logStatement?: NodeLogStatement;
  variableDeclaration?: NodeVariableDeclaration;
}