/**
 * RADIUM COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { Nodes } from './interfaces/interfaces';

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
          generatedCode += `console.log(${statement.logStatement.expression.token.value}); \n`;
        }

      } else if (statement.variableDeclaration) {

        if (statement.variableDeclaration.token === 'var' && statement.variableDeclaration.identifier.type === 'alpha_numeric') {
          const identifier = statement.variableDeclaration.identifier.value;
          const value = statement.variableDeclaration.value.value;

          generatedCode += `const ${identifier} = ${value}; \n`;
        }

      }

    }

    return generatedCode;

  }

}

export default Generator;