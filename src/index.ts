/**
 * RADIUM COMPILER
 *
 * Copyright (C) 2024 - Marwin
*/

import { readFileSync } from 'fs';
import { join } from 'path';
import tokenize from './tokenization';
import Parser from './parser';

const fileToRead: string | undefined = process.argv[2];
console.log('fileToRead', fileToRead ?? 'No file to read');

if (fileToRead) {

  let path: string;

  try {

    path = join(__dirname, `../${fileToRead}`);
    console.log('path', path);

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
    console.log('AST: ', ast);

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