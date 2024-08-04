# The Radon Programming Language
## This is a concept and not yet implemented

### Entry Point
```Radon
fun main() {
  // Code here
}
```

### Variables
```Radon
// Immutable Variable
foo := 'Hello'

// Mutable Variables
mut foo := 'Hello'

// Variables with custom Types
foo > CustomType := customVariable
```

### Functions
```Radon
fun foo(arg1 > Int, arg2 > Int) > Int {
  return arg1 + arg2
}

foo(1, 2)
```

### Control Flow
```Radon

if (condition) {
  // Code here
} else {
  // Code here
}

while (condition) {
  // Code here
}

mut i := 0
for (i < 10) {
  i++
}
```

### Types
```Radon
// Integer
foo > Int := 1

// Float
foo > Float := 1.0

// Boolean
foo > Bool := true

// String
foo > String := 'Hello'

// Custom Type
struct CustomType {
  x > Int
  y > String
  z > Float
}

foo > CustomInterface := {
  x: 1,
  y: 'Hello',
  z: 1.0
}
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

fn main() {
  name > String := std.input('Enter your name: ')

  // Print does not require an import as it is a built-in function
  print('Hello, ' + name)
}
```
