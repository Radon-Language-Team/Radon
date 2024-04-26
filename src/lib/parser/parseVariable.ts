import { Token, NodeVariableDeclaration, TokenType, Nodes, validVariableTypes, TokenCategory, validVariableTypesEnum } from '../../interfaces/interfaces';

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

  let variableIdentifier: Token | undefined = { type: TokenType.alpha_numeric, category: TokenCategory.identifier, line: 0, value: '' };
  let variableValue: Token | undefined = { type: TokenType.int_literal, category: TokenCategory.identifier, line: 0, value: '' };

  while (peek()) {

    // Consume the 'var' keyword
    currentToken = consume();

    // Consume the variable identifier
    variableIdentifier = consume();

    if (variableIdentifier.type === TokenType.alpha_numeric) {
      if (checkIfInitialized(variableIdentifier.value)) {
        console.log(`Variable ${variableIdentifier.value} already initialized`);
        errorHasOccured = true;
        break;
      }
    } else {
      break;
    }

    // Consume the ':'
    if (peek()?.type !== TokenType.colon) {
      errorHasOccured = true;
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
      break;
    } else {
      // Consume the givenType
      currentToken = consume();
    }

    // Consume the '=' keyword
    if (peek()?.type !== TokenType.equal) {
      errorHasOccured = true;
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
        console.log(`Invalid type - Expected ${givenType.value}, got ${actualType}`);
        errorHasOccured = true;
        break;
      }
    } else if (peek()?.type === TokenType.quote && peek(1)?.category === TokenCategory.char || TokenCategory.string && peek(2)?.type === TokenType.quote) {
      // Consume the '
      currentToken = consume();

      // Consume the string/char
      variableValue = consume();
      actualType = validVariableTypesEnum[variableValue.type as keyof typeof validVariableTypesEnum];

      if (givenType.value !== actualType) {
        console.log(`Invalid type - Expected ${givenType.value}, got ${actualType}`);
        errorHasOccured = true;
        break;
      }

      // Consume the closing '
      currentToken = consume();
    } else {
      console.log('Invalid type - Not a number or a string/char');
      errorHasOccured = true;
      break;
    }

    // TODO: Implement support for concatenation of strings and addition of numbers
    if (peek()?.type !== TokenType.semi_colon) {
      console.log(`Expected semicolon, got ${peek()?.type}`);
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
    },
    consumedTokens,
  };

};

export default parseVariable;