import { readFileSync } from 'fs';
import { join } from 'path';

const fileToRead: string | undefined = process.argv[2];
console.log('fileToRead', fileToRead ?? 'No file to read');

if (fileToRead) {

  const path = join(__dirname, `../${fileToRead}`);

  if (!path) {
    //
    console.log('File not found');
    process.exit(1);

  }

  const content = readFileSync(path, 'utf-8');
  console.log(`File content: \n\n${content}`);
  process.exit(0);

} else {

  console.log('No file to read');
  process.exit(1);

}