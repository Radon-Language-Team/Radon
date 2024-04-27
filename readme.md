# Radon Compiler

Radon is my own attempt at creating a programming language. <br>
Radon is a compiled language and is designed to be simple and easy to use.

The compiler is written in TypeScript and is compiled to JavaScript. <br>
The JavaScript code is then run using Node.js. <br>
I am aware that this is not the most efficient way to create a compiler, but it is the easiest way for me to get started. <br>
I am planning to rewrite the compiler in the V Programming Language once it is more stable.

This is a hobby project and is not intended to be used in production. <br>
The goal of this project is to learn more about compilers and programming languages.<br>
One day, the compiler itself might be written in Radon. Who knows 🤷‍♂️

> [!IMPORTANT]
> As of now, you are required to have Node.js installed on your machine to run the compiler.

## Features

- [x] Variable declaration - You can find a list of valid types [here](#types)

_This is a work in progress and more features will be added soon._

## Example

```Radon
!! Define two variables of type $int and assign them values 10 and 20.
var x: $int = 10;
var y: $int = 20;

!! Define a variable of type $string and assign it a value 'Hello'.
var a: $string = 'Hello';
var b: $char = 'A';

!! Print the sum of the two variables of type $int and the two variables of type $string.
log(x + y);
log(a);
log(b);
```

> [!NOTE]
> The above code will output:<br>
> ```Hello, world how are you?```<br>
> ```20``` <br>
> ```20```

> [!IMPORTANT]
> In Radon, all variables must be declared with a type.<br>
> The type declaration is not optional and must be included when declaring a variable.<br>
> The syntax for declaring a variable is ```var <variable_name>: $<type> = <value>;```

## Types
```Radon
$int
$char
$string
```

## Usage

To compile a Radon file, use the following command:

```bash
npm run compile <file>
```
> [!NOTE]
> This will build the Compiler and compile the Radon file.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Pixeled](https://www.youtube.com/@pixeled-yt) (For the inspiration to create my own programming language)