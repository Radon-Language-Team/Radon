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

    let generatedCode = '';

    if (!this.parsedStatements) {

      throw new Error('No parsed statements to generate code from');

    }

    for (const statement of this.parsedStatements) {

      if (statement.quitStatement) {

        if (statement.quitStatement.token === 'quit' && statement.quitStatement.expression.token.type === 'int_literal') {
          generatedCode += `return ${statement.quitStatement.expression.token.value}; \n`;
        }

      } else if (statement.logStatement) {

        if (statement.logStatement.token === 'log' && statement.logStatement.expression.token.type === 'int_literal') {
          generatedCode += `console.log(${statement.logStatement.expression.token.value}); \n`;
        }

      } else if (statement.variableDeclaration) {

        if (statement.variableDeclaration.token === 'let' && statement.variableDeclaration.identifier.type === 'alpha_numeric') {
          const identifier = statement.variableDeclaration.identifier.value;
          const value = statement.variableDeclaration.value.value;

          generatedCode += `let ${identifier} = ${value}; \n`;
        } else if (statement.variableDeclaration.token === 'const' && statement.variableDeclaration.identifier.type === 'alpha_numeric') {
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