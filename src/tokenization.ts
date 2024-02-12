/**
 * RADIUM COMPILER TOKENIZATION
 *
 * Radium is my own programming language. This file contains the tokenization
 * Copyright (C) 2024 - Marwin Eder
 */

enum TokenType {
  _out,
  int_literal,
  semi_colon,
}

interface Token {
  type: TokenType;
  value?: string;
}

/**
 * Tokenizes the input.
 *
 * Tokenization is the process of converting a string into a list of tokens
 *
 * @param input {string} - The input to tokenize
 * @returns {Token[]} - The list of tokens
 */
const tokenize = (input: string): Token[] => {

  for (const char of input) {

    console.log('char', char);

  }

};

export { tokenize };