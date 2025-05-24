# 🌟 Radon Language Planned Features

A living list of features planned for the Radon programming language. Use this roadmap to track upcoming work and share ideas.

---

## 🚀 Next Up

### 1. Function Calls  
- Call Radon functions with arguments  
- Enforce arity and type checks  

```radon
react greet(string name):void {
  println(name)
}

react main():int {
  greet("Marwin")
  emit 0
}
```

---

### 2. String Type  
- Parse string literals  
- Map Radon `string` → C `char*`  
- Support in expressions and `println`  

```radon
element msg = "Hello, World!"
println(msg)
```

---

### 3. Built-in I/O: `println`  
- Define in `core.rad` as an intrinsic  
- Transpile to C `printf("%s\n", ...)`  

```radon
react main():int {
  println("Hi there!")
  emit 0
}
```

---

### 4. Optional Arguments  
- Syntax: `int ?x` or `int ?x = default`  
- Inject default values in generated C  

```radon
react foo(int ?n = 42):int {
  emit n
}
```

---

### 5. Sum-Type Arguments (Union Types)  
- Syntax: `int|float x`  
- Generate tagged unions in C  

```radon
react foo(int|float number):int {
  emit number
}
```

---

### 6. Expanded Operators & Expressions  
- Arithmetic: `+`, `-`, `*`, `/`, `%`  
- Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`  
- Correct precedence & associativity  

---

### 7. Control Flow  
- **If statements**  

  ```radon
  react main():int {
    element x = 10
    if x > 5 {
      emit 1
    } else {
      emit 0
    }
  }
  ```

- **Loops** (`while`, `for`)  
- `break` / `continue`

---

## 📅 Future Ideas

- Full type system (user-defined types, generics)  
- Standard library in Radon (`core.rad`)  
- Documentation site & tutorials  
- AST visualization and `--debug-ast` flag  
- REPL improvements (syntax highlighting, history)