/**
 * RADON COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { Nodes, TokenType } from '../interfaces/interfaces';
import throwError from '../lib/errors/throwError';

class Generator {

  private parsedStatements: Nodes[] | undefined;

  constructor(parsedStatements: Nodes[] | undefined) {
    this.parsedStatements = parsedStatements;
  }

  public generate(): string | undefined {

    const validExpressionTypes = ['int_literal', 'alpha_numeric'];
    let generatedCode = '';

    if (!this.parsedStatements) {

      return throwError('Generator', 'No parsed statements to generate code from', undefined);

    }

    for (const statement of this.parsedStatements) {

      if (statement.quitStatement) {

        if (statement.quitStatement.token === TokenType.quit && validExpressionTypes.includes(statement.quitStatement.expression.token.type)) {
          generatedCode += `return ${statement.quitStatement.expression.token.value}; \n`;
        }

      } else if (statement.logStatement) {

        if (statement.logStatement.token === TokenType.log && validExpressionTypes.includes(statement.logStatement.expression.token.type)) {

          let logContent = '';
          logContent += statement.logStatement.expression.token.value;

          // If we find additional expressions, we add them to the log content
          // We dont need to worry about the type of the additional expressions as the parser has already validated them
          if (statement.logStatement.additionalExpressions) {

            for (const expression of statement.logStatement.additionalExpressions.tokens) {

              if (validExpressionTypes.includes(expression.type)) {
                logContent += ` + ${expression.value}`;
              }
            }
          }
          generatedCode += `console.log(${logContent}); \n`;
        }

      } else if (statement.variableDeclaration) {

        if (statement.variableDeclaration.token === TokenType._var && statement.variableDeclaration.identifier.type === TokenType.alpha_numeric) {
          const identifier = statement.variableDeclaration.identifier.value;
          const value = statement.variableDeclaration.value.value;

          let valueContent = '';

          // If the value is a string or char, we add it to the value content
          if (statement.variableDeclaration.value.type === TokenType.char || statement.variableDeclaration.value.type === TokenType.string) {
            valueContent += `'${value}'`;
          } else {
            valueContent += value;
          }

          if (statement.variableDeclaration.additionalExpressions) {

            for (const expression of statement.variableDeclaration.additionalExpressions.tokens) {
              if (expression.type === TokenType.string || expression.type === TokenType.char) {
                valueContent += ` + '${expression.value}'`;
              } else {
                valueContent += ` + ${expression.value}`;
              }
            }
          }
          generatedCode += `const ${identifier} = ${valueContent}; \n`;
        }
      }
    }
    return generatedCode;
  }
}

export default Generator;