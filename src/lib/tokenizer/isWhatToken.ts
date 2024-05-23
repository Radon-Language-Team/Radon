export const isAlnum = (inputToTest: string | undefined): boolean => {
  if (inputToTest) {
    if (inputToTest.match(/^[a-zA-Z]+$/)) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
};

export const isInt = (input: string | number | undefined): boolean => {
  if (input) {
    if (input.toString().match(/^[0-9]+$/)) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
};

export const isWhitespace = (input: string | number | undefined): boolean => {
  if (input) {
    if (input.toString().match(/^\s+$/)) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
};

export const isOperator = (input: string | number | undefined): boolean => {
  if (input) {
    if (input.toString().match(/^[=+\-*/]+$/)) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
};

export const isSpecialCharacter = (input: string | number | undefined): boolean => {
  if (input) {
    if (input.toString().match(/[:$!']/)) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
};