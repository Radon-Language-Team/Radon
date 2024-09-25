# The Radon Programming Language
## This is a concept and not yet implemented

### Entry Point
```Radon
proc main() {
  // Code here
}
```

### Variables
```Radon
// Immutable Variable
foo := 'Hello';

// Mutable Variables
mut foo := 'Hello';

// Variables with custom Types
foo: CustomType := customVariable;

// Reassigning a mutable variable
foo = 'New Value';
```

### Functions
```Radon
proc foo(arg1 Int, arg2 Int) -> Int {
  return arg1 + arg2;
}

foo(1, 2);
```

### Control Flow
```Radon
match condition {
  true => {
    // Code here
  }
  false => {
    // Code here
  }
}

loop {
  // Infinite loop
  if condition {
    break
  }
}

mut i := 0;
for i in 0..10 {
  i++
}
```

### Types
```Radon
// Integer
foo: Int := 1;

// Float
foo: Float := 1.0;

// Boolean
foo: Bool := true;

// String
foo: String := 'Hello';

// Custom Type
record CustomType {
  x: Int
  y: String
  z: Float
};

// Initialize custom type
foo: CustomType := {x: 1, y: 'Hello', z: 1.0};
```

### Comments
```Radon
// Single Line Comment

/*
  Multi
  Line
  Comment
*/
```

### Full Example
```Radon
import 'std'

proc main() {
  name: String := std.input('Enter your name: ');

  // Print does not require an import as it is a built-in function
  print('Hello, ' + name);
}
```
