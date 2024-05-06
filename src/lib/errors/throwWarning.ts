/**
 * Throws a warning with the given message and line number
 * 
 * @param kind Where the warning occurred (e.g. "Tokenizer")
 * @param message The error message
 * @param line The line number where the warning occurred
 */
const throwWarning = (kind: string, message: string, line: number | undefined): undefined => {

  const warningMessage = `\n\nRADON COMPILER WARNING - ${kind.toLocaleUpperCase()}: ${message.replace('\r', '')} ${line ? `at line ${line}` : ''}`;
  console.warn(`\u001b[35m${warningMessage}\u001b[0m`);

};

export default throwWarning;