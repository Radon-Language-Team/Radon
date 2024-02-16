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

  // We generate JS Code. Radium compiles to JavaScript.

  public generate(): string {

    let generatedCode = '';

    if (!this.parsedStatements) {

      throw new Error('No parsed statements to generate code from');

    }

    for (const statement of this.parsedStatements) {
      
      if (statement.quitStatement.token === 'quit' && statement.quitStatement.expression.token.type === 'int_literal') {
        generatedCode += `return ${statement.quitStatement.expression.token.value}; \n`;
      }
    
    }

    return generatedCode;

  }

}

export default Generator;