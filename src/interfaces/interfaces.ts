/* eslint-disable no-shadow */
/**
 * RADON COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

/**
 * The TokenType enum is used to categorize the types of tokens
 * 
 * It allows us to translate the token into a more readable format
 * Like open_paren to ( or close_paren to )
 */
export enum TokenType {
  quit = 'quit',
  log = 'log',
  int_literal = 'int_literal',
  alpha_numeric = 'alpha_numeric',
  char = 'char',
  string = 'string',
  _var = 'var',
  open_paren = '(',
  close_paren = ')',
  semi_colon = ';',
  equal = '=',
  colon = ':',
  plus = '+',
  dollar_sign = '$',
  quote = '\'',
  exclamation_mark = '!',
  star = '*',
  single_line_comment = '!!',
}

export const validVariableTypes = ['int', 'string', 'char'];

/**
 * The validVariableTypesEnum enum is used to categorize the types of variables
 * 
 * This way, we can easily identify the type of variable we are dealing with
 */
export enum validVariableTypesEnum {
  int_literal = 'int',
  alpha_numeric = 'alpha_numeric',
  string = 'string',
  char = 'char'
}

/**
 * The TokenCategory enum is used to categorize the tokens
 * 
 * This way, we can easily identify the type of token we are dealing with
 * This will make it much easier to parse the tokens and generate the AST
 */
export enum TokenCategory {
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
  // This is a comment, like !! or !!* ... *!!
  comment = 'comment'
}

/**
 * The Token interface is used to define the structure of a token
 * 
 * A token is a single unit of a program, like a variable, a string, a number, or a keyword
 * Tokens have a type, a category, a line number, and an optional value (for variables, strings, and numbers)
 */
export interface Token {
  type: TokenType;
  category : TokenCategory;
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

export interface SingleLineComment {
  token: TokenType;
  value: string;
}

export interface Nodes {
  quitStatement?: NodeQuitStatement;
  logStatement?: NodeLogStatement;
  variableDeclaration?: NodeVariableDeclaration;
  singleLineComment?: SingleLineComment;
}