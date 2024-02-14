/**
 * RADIUM COMPILER INTERFACES
 *
 * Radium is my own programming language. This file contains the interfaces used in the compiler
 * Copyright (C) 2024 - Marwin Eder
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

export interface NodeReturnStatement {
  token: TokenType._return;
  expression: NodeExpression;
}