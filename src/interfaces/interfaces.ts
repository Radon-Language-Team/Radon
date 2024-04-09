/**
 * Radon COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { TokenType } from '../tokenization';

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