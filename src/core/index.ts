/* eslint-disable @typescript-eslint/no-explicit-any */
/**
 * RADON COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'fs';
import { join } from 'path';
import tokenize from './tokenization';
import Parser from './parser';
import Generator from './generation';

function removeNewLines(code: string): string {
  return code.replace(/\r?\n|\r/g, '');
}

const compiler = async () => {

  const fileToRead: string | undefined = process.argv[2];

  if (fileToRead) {

    let path: string;

    try {

      path = join(__dirname, `../../${fileToRead}`);

    } catch (error) {

      console.log('Error: ', error);
      process.exit(1);

    }

    if (!path) {

      console.log('File not found');
      process.exit(1);

    }

    const content = readFileSync(path, 'utf-8');
    // console.log(removeNewLines(content));

    try {

      const tokens = tokenize(removeNewLines(content));
      // console.log('Tokens: ', tokens);

      if (!tokens) {
        console.log('No tokens found');
        process.exit(1);
      }

      const parser = new Parser(tokens);
      const ast = parser.parse();
      // console.log('AST: ', ast);
      const generatedCode = new Generator(ast);
      const codeToWrite = generatedCode.generate();

      if (!codeToWrite) {
        console.log('No code to write');
        process.exit(1);
      }


      const fileName = fileToRead.split('.')[0];

      if (!fileName) {
        console.log('File name not found');
        process.exit(1);
      }

      const outputPath = join(__dirname, `../../radon_output/${fileName}.js`);
      const outputDir = 'radon_output';

      if (!existsSync(outputDir)) {
        console.log('[INFO] Radon output directory does not exist. Creating one...');
        await mkdirSync(outputDir);
        console.log('[INFO] Directory created successfully! Writing to file...');
      }

      writeFileSync(outputPath, codeToWrite);
      // console.log(`[SUCCESS] File ${fileName}.js written to ${outputPath} successfully!`);
      console.log(`\u001b[32m[SUCCESS] File ${fileName}.js written to ${outputPath} successfully!\u001b[39m`);

    } catch (error) {
      
      console.log(error);
      process.exit(1);

    }
    
    finally {

      process.exit(0);

    }
  } else {

    console.log('Incorrect usage Radon usage: npm  run compile <file-to-compile>');
    process.exit(1);

  }
};

compiler();