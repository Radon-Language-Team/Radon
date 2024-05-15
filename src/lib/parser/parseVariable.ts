import { Token, NodeVariableDeclaration, TokenType, Nodes, validVariableTypes, TokenCategory, validVariableTypesEnum } from '../../interfaces/interfaces';
import throwWarning from '../errors/throwWarning';

interface ParseVariable {
  success: boolean;
  errorMessage?: string;
  node: NodeVariableDeclaration | undefined;
  consumedTokens: number;
}

/**
 * Parses a variable declaration
 * 
 * @param tokens The tokens from the var keyword on
 * @param parsedStatements The parsed statements so far
 * @returns {ParseVariable} The parsed variable declaration
 */
const parseVariable = (tokens: Token[], parsedStatements: Nodes[] | undefined): ParseVariable => {

  let index = 0;
  let consumedTokens = 0;
  let currentToken = tokens[index];
  let errorHasOccured = false;

  const peek = (offset: number = 0): Token | undefined => {
    if (index + offset >= tokens.length) {
      return undefined;
    }
    return tokens[index + offset];
  };

  const consume = (): Token => {
    consumedTokens++;
    return currentToken = tokens[index++];
  };

  const checkIfInitialized = (variableIdentifier: string | undefined): boolean => {
    if (!variableIdentifier || !parsedStatements) {
      return false;
    }
    for (const statement of parsedStatements) {
      if (statement.variableDeclaration) {
        if (statement.variableDeclaration.identifier.value === variableIdentifier) {
          return true;
        } else {
          continue;
        }
      } else {
        continue;
      }
    }
    return false;
  };

  const returnVariableType = (variableName: string | undefined): string | undefined => {
    if (!variableName) {
      return undefined;
    }
    for (const statement of parsedStatements ?? []) {
      if (statement.variableDeclaration) {
        if (statement.variableDeclaration.identifier.value === variableName) {
          return validVariableTypesEnum[statement.variableDeclaration.value.type as keyof typeof validVariableTypesEnum];
        } else {
          continue;
        }
      } else {
        continue;
      }
    }
    return undefined;
  };

  const returnVariableValue = (variableName: string | undefined): string | undefined => {
    if (!variableName) {
      return undefined;
    }
    for (const statement of parsedStatements ?? []) {
      if (statement.variableDeclaration) {
        if (statement.variableDeclaration.identifier.value === variableName) {
          // check for additional expressions
          if (statement.variableDeclaration.additionalExpressions) {
            let value = statement.variableDeclaration.value?.value;
            if (!value) {
              return undefined;
            }
            for (const additionalExpression of statement.variableDeclaration.additionalExpressions) {
              value += additionalExpression.value;
            }
            return value;
          } else {
            return statement.variableDeclaration.value.value;
          }
        } else {
          continue;
        }
      } else {
        continue;
      }
    }
    return undefined;
  };

  let variableIdentifier: Token | undefined = { type: TokenType.alpha_numeric, category: TokenCategory.identifier, line: 0, value: '' };
  let variableValue: Token | undefined = { type: TokenType.int_literal, category: TokenCategory.identifier, line: 0, value: '' };
  const additionalValues: Token[] = [];

  while (peek()) {

    // Consume the 'var' keyword
    currentToken = consume();

    // Consume the variable identifier
    variableIdentifier = consume();

    if (variableIdentifier.type === TokenType.alpha_numeric) {
      if (checkIfInitialized(variableIdentifier.value)) {
        throwWarning('Variable Declaration', `Variable ${variableIdentifier.value} already initialized`, undefined);
        errorHasOccured = true;
        break;
      }
    } else {
      break;
    }

    // Consume the ':'
    if (peek()?.type !== TokenType.colon) {
      errorHasOccured = true;
      throwWarning('Variable Declaration', 'Expected colon', undefined);
      break;
    } else {
      currentToken = consume();
    }

    // Consume the '$' keyword and then peek the type
    currentToken = consume();

    /**
     * The type the user specified for the variable -> int, string, char
     */
    const givenType = peek();

    if (currentToken.type !== TokenType.dollar_sign || !givenType || !givenType.value || !validVariableTypes.includes(givenType.value)) {
      errorHasOccured = true;
      throwWarning('Variable Declaration', 'Can not assign this type', undefined);
      break;
    } else {
      // Consume the givenType
      currentToken = consume();
    }

    // Consume the '=' keyword
    if (peek()?.type !== TokenType.equal) {
      errorHasOccured = true;
      throwWarning('Variable Declaration', 'Expected equal sign', undefined);
      break;
    } else {
      currentToken = consume();
    }

    // The next token can either be a number, or a quote, in which case the token after that should be a string/char

    /**
     * The actual type of the variable. Checked with the variable enum
     */
    let actualType;

    if (peek()?.category === TokenCategory.int_literal) {

      currentToken = consume();
      variableValue = currentToken;
      // To determine the actual type of the variable, we give the toke type into the enum
      actualType = validVariableTypesEnum[variableValue.type as keyof typeof validVariableTypesEnum];

      if (givenType.value !== actualType) {
        throwWarning('Variable Declaration', `Invalid type - Expected ${givenType.value}, got ${actualType}`, undefined);
        errorHasOccured = true;
        break;
      }

      if (peek()?.type === TokenType.plus) {

        while (peek()?.type === TokenType.plus) {

          currentToken = consume();

          if (peek()?.category !== TokenCategory.int_literal) {

            throwWarning('Variable Declaration', 'Invalid value - Expected Number', undefined);
            errorHasOccured = true;
            break;

          } else {

            currentToken = consume();
            additionalValues.push(currentToken);

          }
        }
      }

    } else if (peek()?.type === TokenType.quote && peek(1)?.category === TokenCategory.char || TokenCategory.string && peek(2)?.type === TokenType.quote) {
      // Consume the '
      currentToken = consume();

      // Consume the string/char
      variableValue = consume();
      actualType = validVariableTypesEnum[variableValue.type as keyof typeof validVariableTypesEnum];

      if (givenType.value !== actualType) {
        throwWarning('Variable Declaration', `Invalid type - Expected ${givenType.value}, got ${actualType}`, undefined);
        errorHasOccured = true;
        break;
      }

      // Consume the closing '
      currentToken = consume();

      if (peek()?.type === TokenType.plus) {

        while (peek()?.type === TokenType.plus) {

          currentToken = consume();

          if (peek()?.type === TokenType.quote && peek(1)?.category === TokenCategory.char || TokenCategory.string && peek(2)?.type === TokenType.quote) {

            currentToken = consume();
            const additionalValue = consume();
            actualType = validVariableTypesEnum[additionalValue.type as keyof typeof validVariableTypesEnum];

            if (givenType.value !== actualType) {
              throwWarning('Variable Declaration', `Invalid type - Expected ${givenType.value}, got ${actualType}`, undefined);
              errorHasOccured = true;
              break;
            }

            currentToken = consume();
            additionalValues.push(additionalValue);

          } else {
            throwWarning('Variable Declaration', 'Invalid value - Expected String/Char', undefined);
            errorHasOccured = true;
            break;
          }
        }
      }

    } else if (peek()?.type === TokenType.alpha_numeric) {

      currentToken = consume();

      // We go through our parsed statements and return type of the variable
      // "Hello" -> "string" - These are being given by the tokenizer
      actualType = returnVariableType(currentToken.value);

      if (givenType.value !== actualType) {
        throwWarning('Variable Declaration', `Invalid type - Expected ${givenType.value}, got ${actualType}`, undefined);
        errorHasOccured = true;
        break;
      }

      const tokenType = validVariableTypesEnum[actualType as keyof typeof validVariableTypesEnum] as unknown as TokenType;
      variableValue = { type: tokenType, category: TokenCategory.identifier, line: 0, value: returnVariableValue(currentToken.value) };

      if (peek()?.type === TokenType.plus) {

        while (peek()?.type === TokenType.plus) {

          currentToken = consume();

          if (peek()?.type === TokenType.alpha_numeric) {

            currentToken = consume();
            const additionalValue = currentToken;
            actualType = returnVariableType(additionalValue.value);

            if (givenType.value !== actualType) {
              throwWarning('Variable Declaration', `Invalid type - Expected ${givenType.value}, got ${actualType}`, undefined);
              errorHasOccured = true;
              break;
            }

            const additionalTokenType = validVariableTypesEnum[actualType as keyof typeof validVariableTypesEnum] as unknown as TokenType;
            additionalValues.push({ type: additionalTokenType, category: TokenCategory.identifier, line: 0, value: returnVariableValue(additionalValue.value) });

          } else {
            throwWarning('Variable Declaration', 'Variable + differnt expressions are not yet supported', undefined);
            errorHasOccured = true;
            break;
          }
        }

      }

    } else {
      throwWarning('Variable Declaration', 'Invalid value - Expected Number/String/Char', undefined);
      errorHasOccured = true;
      break;
    }

    if (peek()?.type !== TokenType.semi_colon) {
      throwWarning('Variable Declaration', `Expected semicolon, got ${peek()?.type}`, undefined);
      errorHasOccured = true;
      break;
    } else {
      // Consume the semicolon
      consume();
    }

    break;

  }

  if (errorHasOccured) {
    return {
      success: false,
      errorMessage: 'Invalid variable declaration',
      node: undefined,
      consumedTokens,
    };
  }

  if (!variableIdentifier.value || !variableValue.value) {
    return {
      success: false,
      errorMessage: 'Invalid variable declaration',
      node: undefined,
      consumedTokens,
    };
  }

  return {
    success: true,
    node: {
      token: TokenType._var,
      identifier: variableIdentifier,
      value: variableValue,
      additionalExpressions: additionalValues,
    },
    consumedTokens,
  };

};

export default parseVariable;