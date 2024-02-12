/**
 * RADIUM COMPILER TOKENIZATION
 *
 * Radium is my own programming language. This file contains the tokenization
 * Copyright (C) 2024 - Marwin Eder
 */

// eslint-disable-next-line no-shadow
enum TokenType {
  _return = '_return',
  int_literal = 'int_literal',
  semi_colon = 'semi_colon',
}

interface Token {
  type: TokenType;
  value?: string;
}

const isLetter = (char: string): false | RegExpMatchArray | null => {
  return char.length === 1 && char.match(/[a-z]/i);
};

const isInt = (input: string | number): false | RegExpMatchArray | null => {
  return input.toString().length === 1 && input.toString().match(/[0-9]/);
};

/**
 * Tokenizes the input.
 *
 * Tokenization is the process of converting a string into a list of tokens
 *
 * @param input {string} - The input to tokenize
 * @returns {Token[]} - The list of tokens
 */
const tokenize = (input: string): Token[] => {

  const tokens: Token[] = [];
  let currentBuffer = '';

  for (let i = 0; i < input.length; i++) {

    const char = input[i];

    if (isLetter(char)) {

      currentBuffer += char;
      i++;

      while (isLetter(input[i])) {

        currentBuffer += input[i];
        i++;

      }

      if (currentBuffer === 'return') {

        tokens.push({ type: TokenType._return, value: currentBuffer });
        currentBuffer = '';
        continue;

      } else {

        throw new Error(`Unrecognized token: ${currentBuffer}`);

      }

    } else if (isInt(char)) {

      currentBuffer += char;
      i++;

      while (isInt(input[i])) {

        currentBuffer += input[i];
        i++;

      }

      tokens.push({ type: TokenType.int_literal, value: currentBuffer });
      currentBuffer = '';

    } else if (char === ';') {

      console.log(`Chars left: ${input.slice(i + 1)}`);
      tokens.push({ type: TokenType.semi_colon, value: ';' });
      
    } else if (char === ' ') {

      console.log('Space');
      continue;

    }

  }

  return tokens;

};

export default tokenize;