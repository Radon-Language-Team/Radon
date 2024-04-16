/**
 * RADON COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { Nodes } from '../interfaces/interfaces';

class Generator {

  private parsedStatements: Nodes[] | undefined;

  constructor(parsedStatements: Nodes[] | undefined) {
    this.parsedStatements = parsedStatements;
  }

  public generate(): string {

    const validExpressionTypes = ['int_literal', 'alpha_numeric'];
    let generatedCode = '';

    if (!this.parsedStatements) {

      throw new Error('No parsed statements to generate code from');

    }

    for (const statement of this.parsedStatements) {

      if (statement.quitStatement) {

        if (statement.quitStatement.token === 'quit' && validExpressionTypes.includes(statement.quitStatement.expression.token.type)) {
          generatedCode += `return ${statement.quitStatement.expression.token.value}; \n`;
        }

      } else if (statement.logStatement) {

        if (statement.logStatement.token === 'log' && validExpressionTypes.includes(statement.logStatement.expression.token.type)) {

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

        if (statement.variableDeclaration.token === 'var' && statement.variableDeclaration.identifier.type === 'alpha_numeric') {
          const identifier = statement.variableDeclaration.identifier.value;
          const value = statement.variableDeclaration.value.value;

          let valueContent = '';

          // If the value is a string or char, we add it to the value content
          if (statement.variableDeclaration.value.type === 'string' || statement.variableDeclaration.value.type === 'char') {
            valueContent += `'${value}'`;
          } else {
            valueContent += value;
          }

          if (statement.variableDeclaration.additionalExpressions) {

            for (const expression of statement.variableDeclaration.additionalExpressions.tokens) {
              if (expression.type === 'string' || expression.type === 'char') {
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