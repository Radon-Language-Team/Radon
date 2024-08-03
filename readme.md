<div align="center" style="display:grid;place-items:center;">

<p>
  <a href="https://github.com/Radon-Language-Team" target="_blank"><img width="90" src="https://raw.githubusercontent.com/Radon-Language-Team/Radon/v_rewrite//assets/Radon_Logo.jpeg?sanitize=true">
  </a>
</p>

<h1>Radon Programming Language</h1>

<p>
  <strong>A statically-typed compiled programming language
  </strong>
</p>
</div>

> [!NOTE]
> Switch to the `v_rewrite` branch to see the latest changes.
> Clone the repository and then build the radon binary using the `build.sh` script.
> This requires the `V` Compiler to be installed. This builds both the Linux and Windows binaries.
> `cd` into the `bin` directory and run the `radon` binary.
> You should now be able to run the Radon REPL.

> [!IMPORTANT]
> The Windows Symbolic Link is not working. You will have to run the `radon` binary either from the cloned git repository or from the `bin` directory.

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
