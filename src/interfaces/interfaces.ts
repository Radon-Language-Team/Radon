/* eslint-disable no-shadow */
/**
 * RADON COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { TokenType } from '../core/tokenization';

export const validVariableTypes = ['int', 'string'];
export enum validVariableTypesEnum {
  int_literal = 'int',
  alpha_numeric = 'string'
}

export interface Token {
  type: TokenType;
  line: number;
  value?: string;
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