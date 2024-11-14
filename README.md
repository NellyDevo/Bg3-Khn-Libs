# Bg3 Khonsu Mappings

This repository does not contain anything functionally run for users. Instead, it is by and for developers to aid with the creation of Khonsu (or .khn) condition scripts when creating mods for Baldur's Gate 3.

## Installation

To install, simply download the files of this repository and dump any files beginning with `Khn` into a Lib folder of your choice. This folder should be configured by your preferred lua linter as a library folder in order for the linter to recognize the various classes, functions, and enums.

Then, in your IDE of choice, declare the .khn file you're working with to use Lua syntax highlighting. For example, in VSCode there's a button at the bottom right while you're viewing a file showing what it's currently highlighting as (.khn was Plain Text) in my case.

## Contributing

These mappings are by no means complete! Most of these are an afternoon of work from existing code, chiefly the `CommonConditions` and `CommonConditionsDev` files. `context` was retrieved via a dump of `context` inside the toolkit. A lot of the functions were found through observation or other resources.

Ideally, people will use this syntax highlighting and then as they discover functionality with proven code, contribute to this project so we can grow these mappings and make .khn a bit easier for people to navigate. If you have a contribution, simply submit a pull request and I will have it merged asap.

## License

[MIT](https://choosealicense.com/licenses/mit/)
