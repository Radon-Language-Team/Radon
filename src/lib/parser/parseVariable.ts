import { Token, NodeVariableDeclaration, TokenType } from '../../interfaces/interfaces';

interface ParseVariable {
  success: boolean;
  node: NodeVariableDeclaration | undefined;
}

const parseVariable = (tokens: Token[]): ParseVariable => {

  let index = 0;
  let currentToken = tokens[index];

  const peek = (offset: number = 0): Token | undefined => {
    if (index + offset >= tokens.length) {
      return undefined;
    }
    return tokens[index + offset];
  };

  const consume = (): Token => {
    return currentToken = tokens[index++];
  };

  while (peek()) {
    if (peek()?.type === TokenType._var) {
      consume();
    }
    console.log(currentToken);
    if (peek()?.type === TokenType.alpha_numeric) {
      consume();
    }
    console.log(currentToken);
    return { node: undefined, success: false };
  }

  return { node: undefined, success: false };
};

export default parseVariable;