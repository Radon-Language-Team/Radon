/* eslint-disable @typescript-eslint/no-explicit-any */
/**
 * RADIUM COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'fs';
import { join } from 'path';
import tokenize from './tokenization';
import Parser from './parser';
import Generator from './generation';

const compiler = async () => {

  const fileToRead: string | undefined = process.argv[2];

  if (fileToRead) {

    let path: string;

    try {

      path = join(__dirname, `../${fileToRead}`);

    } catch (error) {

      console.log('Error: ', error);
      process.exit(1);

    }

    if (!path) {

      console.log('File not found');
      process.exit(1);

    }

    const content = readFileSync(path, 'utf-8');

    try {

      const tokens = tokenize(content);
      const parser = new Parser(tokens);
      const ast = parser.parse();
      const generatedCode = new Generator(ast);
      const codeToWrite = generatedCode.generate();


      const fileName = fileToRead.split('.')[0];
      const outputPath = join(__dirname, `../radium_output/${fileName}.js`);
      const outputDir = 'radium_output';

      if (!existsSync(outputDir)) {
        console.log('[INFO] Radium output directory does not exist. Creating one...');
        await mkdirSync(outputDir);
        console.log('[INFO] Directory created successfully! Writing to file...');
      }

      writeFileSync(outputPath, codeToWrite);
      console.log(`[SUCCESS] File ${fileName}.js written to ${outputPath} successfully!`);

    } catch (error) {

      console.log('Tokenization || Parser', error);
      process.exit(1);

    } finally {

      process.exit(0);

    }
  } else {

    console.log('Incorrect usage: npm  run compile <file-to-compile>');
    process.exit(1);

  }
};

compiler();