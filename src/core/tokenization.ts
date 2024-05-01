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
    return this.buffer.replace('\r', '');
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
          return throwError('Tokenizer', `Unexpected end of input -> Expected ${TokenType.quote}`, lineCount);
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

        } else {
          return throwError('Tokenizer', `Unexpected character -> ${stream.peek()} -> Expected '${TokenType.quote}`, lineCount);
        }

      } else if (stream.peek() === TokenType.exclamation_mark) {

        stream.consume();

        // Check if it's a single line comment -> !!
        if (stream.peek() === TokenType.exclamation_mark) {

          stream.consume();

          // We consume until the end of the line
          while (stream.peek() && !isNewLine(stream.peek())) {

            buffer.append(stream.consume());

          }

          tokens.push({ type: TokenType.single_line_comment, line: lineCount, value: buffer.value, category: TokenCategory.comment });
          buffer.clear();

        } else if (stream.peek() === TokenType.star) {
          // Check if it's a multi-line comment -> !*

          stream.consume();

          // If the next character is not a new line, then we need to throw an error since the multi-line comment should always start on a new line
          // if (!isNewLine(stream.peek())) {
          //   return throwError('Tokenizer', 'For single-line comments, please use the correct syntax', lineCount);
          // }

          let linesOccupied = 0;

          // We consume until we find the end of the multi-line comment -> *!
          while (stream.peek() && !(stream.peek() === TokenType.star && stream.peek(1) === TokenType.exclamation_mark)) {

            // If we encounter a new line, we need to make sure the line starts with a *
            if (isNewLine(stream.peek())) {

              // We need to do the same check as above as the next line will always be a new line
              // If the next peek is a star and the one after that is an exclamation mark, then we can break out of the loop
              if (stream.peek(1) === TokenType.star && stream.peek(2) === TokenType.exclamation_mark) {
                break;
              }

              lineCount++;
              linesOccupied++;
              stream.consume();


              if (stream.peek() !== TokenType.star) {
                return throwError('Tokenizer', `Expected '${TokenType.star}' as start of line in multi-line comment`, lineCount);
              }

              // Consume the star
              stream.consume();

            }

            buffer.append(stream.consume());

          }

          // The next character should be a new line
          if (!isNewLine(stream.peek())) {
            return throwError('Tokenizer', 'Expected new line after multi-line comment', lineCount);
          } else {
            stream.consume();
            lineCount++;
          }

          // Consume the * and !
          stream.consume();
          stream.consume();

          // We need to add 2 to the linesOccupied since we need to account for the start and end of the multi-line comment
          tokens.push({ type: TokenType.multi_line_comment_start, line: lineCount, value: buffer.value, category: TokenCategory.comment, linesOccupied: linesOccupied + 2 });
          buffer.clear();
          tokens.push({ type: TokenType.multi_line_comment_end, line: lineCount, category: TokenCategory.comment });

        } else {

          return throwError('Tokenizer', `Unexpected character -> Expected ${TokenType.exclamation_mark} or ${TokenType.star} but got '${stream.peek()}'`, lineCount);

        }

      }

    } else {

      return throwError('Tokenizer', `Unexpected character -> ${stream.peek()}`, lineCount);

    }

  }

  return tokens;

};

export default tokenize;