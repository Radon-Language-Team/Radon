<div align="center" style="display:grid;place-items:center;">

<p>
  <a href="https://github.com/Radon-Language-Team" target="_blank"><img width="90" src="https://raw.githubusercontent.com/Radon-Language-Team/Radon/master/assets/Radon_Logo.jpeg?sanitize=true">
  </a>
</p>

<h1>Radon Programming Language</h1>

<p>
  <strong>A statically-typed compiled programming language
  </strong>
</p>
</div>

## What is Radon?

Radon is a statically-typed compiled programming language that is, unlike other languages, not really focused on how easy it is to code with it. <br>
Instead, Radon provides features that make it more of a convienience to write code, such as `type inference` and `optional function arguments`. <br>
It is my own personal hobby project and I am working on it in my free time. <br>
[Join the Discord Server by the way!!](https://discord.gg/UwKeDFssNH) <br>
The syntax is heavily inspired by the V programming language, which is also used to write the Radon compiler. <br>
The language is still so early in development that it is not even close to being usable for any real-world projects. <br>
Some Radon Code that compiles today:

```radon
proc main() -> int {
  a := 5;
  b := 10;
  c := a + b;
  d := c - 15;
  return d;
}
```

Radon does not do much more yet, but I am working on it and I am planning to add many more features in the future :) <br>

## Planned Features
- [x] Basic Syntax
- [] Basic Type System
- [] Radon Standard Library
- [] Radon Documentation
- [] Radon Website

These might come off as very ambitious, but you gotta aim high, right? <br>

## Contributing
Contributions are always welcome as this is kind of a huge project for me to work on alone. <br>
If you want to contribute, feel free to fork the repository and open a pull request. <br>

## Building Radon

> [!NOTE]
> This requires the `V` Compiler to be installed! <br>
> Clone the repository and then build the radon binary using the `build.vsh` script by running `v run build.vsh`. <br>
> `cd` into the `radon` directory and run the `radon` executable. <br>
> You should now be able to run the Radon REPL.

### Symlinking the Radon Binary

Radon provides an easy way to symlink the binary to your system path. <br>
When you have built the binary, run it as administrator. <br>
Once running, type `symlink` and press enter. <br>
The binary should now be symlinked to your system path. <br>
**Make sure to restart your terminal after running the command.**
