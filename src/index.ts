import { readFileSync } from 'fs';
import { join } from 'path';
import tokenize from './tokenization';

const fileToRead: string | undefined = process.argv[2];
console.log('fileToRead', fileToRead ?? 'No file to read');

if (fileToRead) {

  let path: string;

  // const path = join(__dirname, `../${fileToRead}`);

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
  console.log(`File content: \n\n${content}`);

  console.log('Tokens: ', tokenize(content));

  process.exit(0);

} else {

  console.log('Incorrect usage: npm  run compile <file-to-compile>');
  process.exit(1);

}