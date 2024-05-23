/**
 * Throws an error with the given message and line number
 * 
 * @param kind Where the error occurred (e.g. "Tokenizer")
 * @param message The error message
 * @param line The line number where the error occurred
 */
const throwError = (kind: string, message: string, line: number | undefined): undefined => {

  const errorMessage = `\n\nRADON COMPILER ERROR - ${kind.toLocaleUpperCase()}: ${message.replace('\r', '')} ${line ? `at line ${line}` : ''}`;
  throw new Error(`\u001b[31m${errorMessage}\u001b[0m`);

};

export default throwError;