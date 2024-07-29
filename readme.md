<div align="center" style="display:grid;place-items:center;">

<p>
  <a href="https://github.com/Radon-Language-Team" target="_blank"><img width="90" src="https://raw.githubusercontent.com/Radon-Language-Team/Radon/v_rewrite/Radon_Logo.jpeg?sanitize=true">
  </a>
</p>

<h1>Radon Programming Language</h1>

<p>
  <strong>A statically-typed compiled programming language
  </strong>
</p>
</div>

> [!NOTE]
> Everything from this point on is subject to change.
> It is just an example of what Radon could/would look like.

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
