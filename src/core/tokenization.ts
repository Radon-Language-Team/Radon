/**
 * RADON COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { Token, TokenCategory, TokenType } from '../interfaces/interfaces';
import { isAlnum, isInt, isOperator, isSpecialCharacter, isWhitespace, isNewLine } from '../lib/tokenizer/isWhatToken';
import throwError from '../lib/errors/throwError';

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

/**
 * Tokenizes the input.
 *
 * Tokenization is the process of converting a string into a list of tokens
 *
 * @param input {string} - The input to tokenize
 * @returns {Token[]} - The list of tokens
 */
const tokenize = (input: string): Token[] | undefined => {

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

      if (buffer.value === TokenType.quit) {
        tokens.push({ type: TokenType.quit, line: lineCount, category: TokenCategory.keyword });
        buffer.clear();
      } else if (buffer.value === TokenType.log) {
        tokens.push({ type: TokenType.log, line: lineCount, category: TokenCategory.keyword });
        buffer.clear();
      } else if (buffer.value === TokenType._var) {
        tokens.push({ type: TokenType._var, line: lineCount, category: TokenCategory.keyword });
        buffer.clear();
      }
      else {
        // This should be used for variable names, function names, etc
        tokens.push({ type: TokenType.alpha_numeric, line: lineCount, value: buffer.value, category: TokenCategory.identifier });
        buffer.clear();
      }

    } else if (isInt(stream.peek())) {

      buffer.append(stream.consume());

      while (stream.peek() && isInt(stream.peek())) {
        buffer.append(stream.consume());
      }

      tokens.push({ type: TokenType.int_literal, line: lineCount, value: buffer.value, category: TokenCategory.int_literal });
      buffer.clear();

    } else if (isOperator(stream.peek())) {

      if (stream.peek() === TokenType.equal) {

        tokens.push({ type: TokenType.equal, line: lineCount, category: TokenCategory.expression });
        stream.consume();

      } else if (stream.peek() === TokenType.plus) {

        tokens.push({ type: TokenType.plus, line: lineCount, category: TokenCategory.expression });
        stream.consume();

      } else {

        return throwError('Tokenizer', `Unexpected character -> ${stream.peek()}`, lineCount);

      }

    } else if (stream.peek() === TokenType.open_paren) {

      tokens.push({ type: TokenType.open_paren, line: lineCount, category: TokenCategory.expression });
      stream.consume();

    } else if (stream.peek() === TokenType.close_paren) {

      tokens.push({ type: TokenType.close_paren, line: lineCount, category: TokenCategory.expression });
      stream.consume();

    } else if (stream.peek() === TokenType.semi_colon) {

      tokens.push({ type: TokenType.semi_colon, line: lineCount, category: TokenCategory.expression });
      stream.consume();

    } else if (isNewLine(stream.peek())) {

      stream.consume();
      lineCount++;

    } else if (isWhitespace(stream.peek())) {

      stream.consume();

    } else if (isSpecialCharacter(stream.peek())) {

      if (stream.peek() === TokenType.colon) {

        tokens.push({ type: TokenType.colon, line: lineCount, category: TokenCategory.expression });
        stream.consume();

      } else if (stream.peek() === TokenType.dollar_sign) {

        tokens.push({ type: TokenType.dollar_sign, line: lineCount, category: TokenCategory.expression });
        stream.consume();

      } else if (stream.peek() === TokenType.quote) {

        tokens.push({ type: TokenType.quote, line: lineCount, category: TokenCategory.expression });
        stream.consume();

        // Instead of leaving the loop when we encounter a single quote, we will keep consuming until we find another single quote
        // This way we can get the string value / or if the length is 1 then it's a char
        // eslint-disable-next-line quotes
        while (stream.peek() && stream.peek() !== TokenType.quote) {

          buffer.append(stream.consume());

        }

        if (stream.peek() === undefined) {
          return throwError('Tokenizer', 'Unexpected end of input -> Expected a closing quote', lineCount);
        }

        if (stream.peek() === TokenType.quote) {

          if (buffer.value.length === 1) {

            tokens.push({ type: TokenType.char, line: lineCount, value: buffer.value, category: TokenCategory.char });
            buffer.clear();

          } else {

            tokens.push({ type: TokenType.string, line: lineCount, value: buffer.value, category: TokenCategory.string });
            buffer.clear();

          }

          stream.consume();
          tokens.push({ type: TokenType.quote, line: lineCount, category: TokenCategory.expression });

          // we have successfully consumed the string/char and now need to check for the next token
          // We move out of the loop and continue with the next token
          continue;

        } else {
          return throwError('Tokenizer', `Unexpected character -> ${stream.peek()} -> Expected a closing quote`, lineCount);
        }

      }

    } else {

      return throwError('Tokenizer', `Unexpected character -> ${stream.peek()}`, lineCount);

    }

  }

  return tokens;

};

export default tokenize;