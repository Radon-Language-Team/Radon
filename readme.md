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

Radon is my attempt at creating a programming language. I have no degree in computer science, so I am learning as I go.
This is project is 100% my own work, and I am not using any other programming language as a reference (probably a bad idea).
The Syntax is inspired heavily by the V Programming language which is also used to build Radon.
This is merely a hobby project and will take a long time to complete (if ever).
My goal is to create a language that is easy to use, fast, and might be considered in a small "test" project.
**As of now, Radon is in the very early stages of development.**
**We just have a Lexer and a Parser.**

## Building Radon

> [!NOTE]
> Clone the repository and then build the radon binary using the `build.vsh` script.
> This requires the `V` Compiler to be installed. This builds both the Linux and Windows binaries.
> `cd` into the `bin` directory and run the `radon` binary.
> You should now be able to run the Radon REPL.

When you have built the binary, you can create a symbolic link to the binary in the `bin` directory.
This allows you to run the `radon` command from anywhere in the terminal.
All you have to do is run the REPL with admin permissions and then run the `link` command
Everything is done for you automatically. **Make sure to restart your shell after running the `link` command.**
