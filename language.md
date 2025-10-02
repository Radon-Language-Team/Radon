# Language Manual

A simple `Hello, World!` program in Radon looks like this:  

```go
mixture 'core'

react main() {
  println('Hello, World!')
}
```

---

## The Basics

### Data Types
Radon currently supports the following primitive types:

- `int` → whole numbers (`0`, `10`, `24`, `67`)  
- `string` → sequences of characters (`'This is a string'`, `'H'`)  
- `bool` → truth values (`true`, `false`)  
- `void` → used for functions that do not return a value  

---

### Variables
In Radon, **every variable must be declared** as either an `elem` (element) or an `iso` (isotope).  

- **`elem`** → immutable by default (cannot be changed after initialization)  
- **`iso`** → mutable, meaning its value can be reassigned or updated  

Declaring a variable requires:  
1. a keyword (`elem` or `iso`),  
2. the variable name,  
3. and its initial value.  

Example:
```go
elem name = 'Bob'
elem age = 32
iso dogOwner = false
```

There’s **no need to explicitly annotate types** — the compiler infers them automatically.  
*(Planned: optional type annotations for clarity or stricter checks.)*

---

### Constant Variables
- Normal variables can only be declared **inside a function**.  
- Constants (`elem`) can be declared **outside** of functions.  

```go
elem name = 'Alice'   // constant (known at compile time)

react main() {
  elem fullName = name + ' Daniels'
  println(fullName)
}
```

The key rule being: **constant values must be known at compile time.**

---

### Mutability
`iso` variables can be reassigned, while `elem` variables cannot.

- **Immutable (`elem`)**
```go
elem amount = 5
amount += 5   
^^^^^^^^^^^ > error: 'amount' is immutable
```

- **Mutable (`iso`)**
```go
iso amount = 5
amount += 5
```

This way, immutability is the default (safer, predictable), while mutability is explicit with `iso`.  

---

### Functions

In Radon, functions are declared using the `react` keyword.  

A simple function without parameters looks like this:
```go
react foo() {
  println('Hello')
}
```

#### Return types
If a function does not return anything, you can omit the return type.  
Functions that return values must explicitly declare their return type.  
You return a value using the `emit` keyword:
```go
react addTen() :int {
  emit 10 + 10
}
```

#### Parameters
Functions can also take parameters. Multiple parameters are separated by commas:
```go
react greet(string name, int age) :void {
  println('Hello ${name}')
  println('You are ${toString(age)} years old')
}
```

#### Mutable parameters
By default, parameters are immutable. If you want a parameter to be mutable, you must declare it with `iso`:
```go
react increment(iso int x) :int {
  x++
  emit x
}
```

#### The `main` function
Every Radon program starts execution in the `main` function:
```go
mixture 'core'

react main() :int {
  greet('Alice', 25)
  emit 0
}
```
---

### Control Flow

Radon supports the usual control flow constructs such as `if`/`else` and loops.

#### If / Else
Conditions are written using `if`. Optionally, you can add an `else` branch:
```go
react checkNumber(int x) :void {
  if x > 0 {
    println('Positive')
  } else {
    println('Zero or Negative')
  }
}
```

#### For loops
```go
react loopExample() :void {
  iso loop = true
  iso i = 0
  for loop {
    if i >= 10 {
      loop = false
    }
    i++
  }
}
```