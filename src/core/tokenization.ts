/**
 * RADON COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { Token } from '../interfaces/interfaces';
// eslint-disable-next-line no-shadow
export enum TokenType {
  quit = 'quit',
  log = 'log',
  open_paren = 'open_paren',
  close_paren = 'close_paren',
  int_literal = 'int_literal',
  alpha_numeric = 'alpha_numeric',
  char = 'char',
  string = 'string',
  semi_colon = 'semi_colon',
  _var = 'var',
  equal = 'equal',
  colon = 'colon',
  plus = 'plus',
  dollar_sign = 'dollar_sign',
  open_quote = 'open_quote',
  close_quote = 'close_quote',
}

class Buffer {

  private buffer: string;

  constructor() {
    this.buffer = '';
  }

  public append(char: string | number | undefined): void {
    if (char) {
      this.buffer += char;
    }
  }

  public clear(): void {
    this.buffer = '';
  }

  public get value(): string {
    return this.buffer;
  }
}

class CharacterStream {

  private readonly src: string;
  private index: number;

  constructor(src: string) {
    this.src = src;
    this.index = 0;
  }

  public peek(offset: number = 0): string | undefined {
    if (this.index + offset >= this.src.length) {
      return undefined;
    }
    return this.src[this.index + offset];
  }

  public consume(): string | undefined {
    if (this.index >= this.src.length) {
      return undefined;
    }
    return this.src[this.index++];
  }
}

const isAlnum = (inputToTest: string | undefined): boolean => {
  if (inputToTest) {
    if (inputToTest.match(/^[a-zA-Z]+$/)) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
};

const isInt = (input: string | number | undefined): boolean => {
  if (input) {
    if (input.toString().match(/^[0-9]+$/)) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
};

const isWhitespace = (input: string | number | undefined): boolean => {
  if (input) {
    if (input.toString().match(/^\s+$/)) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
};

const isNewLine = (input: string | number | undefined): boolean => {
  if (input) {
    if (input.toString().match(/^\n+$/)) {
      return true;
    } else {
      return false;
    }
  } else {
    if (input === '') {
      return true;
    }
    return false;
  }
};

const isOperator = (input: string | number | undefined): boolean => {
  if (input) {
    if (input.toString().match(/^[=+\-*/]+$/)) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
};

const isSpecialCharacter = (input: string | number | undefined): boolean => {
  if (input) {
    if (input.toString().match(/[:$']/)) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
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
  const stream = new CharacterStream(input);

  const buffer = new Buffer();
  let lineCount = 1;

  while (stream.peek()) {

    if (isAlnum(stream.peek())) {

      buffer.append(stream.consume());

      while (stream.peek() && isAlnum(stream.peek())) {
        buffer.append(stream.consume());
      }

      if (buffer.value === 'quit') {
        tokens.push({ type: TokenType.quit, line: lineCount });
        buffer.clear();
      } else if (buffer.value === 'log') {
        tokens.push({ type: TokenType.log, line: lineCount });
        buffer.clear();
      } else if (buffer.value === 'var') {
        tokens.push({ type: TokenType._var, line: lineCount });
        buffer.clear();
      }
      else {
        // This should be used for variable names, function names, etc
        tokens.push({ type: TokenType.alpha_numeric, line: lineCount, value: buffer.value });
        buffer.clear();
      }

    } else if (isInt(stream.peek())) {

      buffer.append(stream.consume());

      while (stream.peek() && isInt(stream.peek())) {
        buffer.append(stream.consume());
      }

      tokens.push({ type: TokenType.int_literal, line: lineCount, value: buffer.value });
      buffer.clear();

    } else if (isOperator(stream.peek())) {

      if (stream.peek() === '=') {

        tokens.push({ type: TokenType.equal, line: lineCount });
        stream.consume();

      } else if (stream.peek() === '+') {

        tokens.push({ type: TokenType.plus, line: lineCount });
        stream.consume();

      } else {

        throw new Error(`Unexpected character -> ${stream.peek()}`);

      }

    } else if (stream.peek() === '(') {

      tokens.push({ type: TokenType.open_paren, line: lineCount });
      stream.consume();

    } else if (stream.peek() === ')') {

      tokens.push({ type: TokenType.close_paren, line: lineCount });
      stream.consume();

    } else if (stream.peek() === ';') {

      tokens.push({ type: TokenType.semi_colon, line: lineCount });
      stream.consume();

    } else if (isNewLine(stream.peek())) {

      stream.consume();
      lineCount++;

    } else if (isWhitespace(stream.peek())) {

      stream.consume();

    } else if (isSpecialCharacter(stream.peek())) {

      if (stream.peek() === ':') {

        tokens.push({ type: TokenType.colon, line: lineCount });
        stream.consume();

      } else if (stream.peek() === '$') {

        tokens.push({ type: TokenType.dollar_sign, line: lineCount });
        stream.consume();

        // eslint-disable-next-line quotes
      } else if (stream.peek() === "'") {

        tokens.push({ type: TokenType.open_quote, line: lineCount });
        stream.consume();

        // Instead of leaving the loop when we encounter a single quote, we will keep consuming until we find another single quote
        // This way we can get the string value / or if the length is 1 then it's a char
        // eslint-disable-next-line quotes
        while (stream.peek() && stream.peek() !== "'") {

          buffer.append(stream.consume());

        }

        if (stream.peek() === undefined) {
          throw new Error('Unexpected end of input -> Expected a closing quote');
        }

        // eslint-disable-next-line quotes
        if (stream.peek() === "'") {

          if (buffer.value.length === 1) {

            tokens.push({ type: TokenType.char, line: lineCount, value: buffer.value });
            buffer.clear();

          } else {

            tokens.push({ type: TokenType.string, line: lineCount, value: buffer.value });
            buffer.clear();

          }

          stream.consume();
          tokens.push({ type: TokenType.close_quote, line: lineCount });

          // we have successfully consumed the string/char and now need to check for the next token
          // We move out of the loop and continue with the next token
          continue;

        } else {
          throw new Error(`Unexpected character at line ${lineCount} -> ${stream.peek()} -> Expected a closing quote`);
        }

      }

    } else {

      throw new Error(`Unexpected character -> ${stream.peek()}`);

    }

  }

  return tokens;

};

export default tokenize;