# unoweb_flutter
welcome to the project. unoweb_flutter is a remake of a remake of [unoweb](https://github.com/paytontech/unoweb) (im writing this on my phone and idk markup by heart. lets hope i got that link right!)<br/>unoweb was a little JS minigame i made which **tried** to recreate UNO in pure JS, without any frameworks. this was, as you can probably assume, a nightmare. i had this huge render function that sucked and generally was bad. it limited my ability to add new features to the game and made it overall worse.<br/>so, i aimed to rewrite it using a JS framework. I first tried React, then Vue, then React again, and finally realized that i should give up. and then, in my moment if weakness, i had a great idea: <br/> **FLUTTER**<br/>So, i rewrote the game in flutter, and even added some of the features i'd been looking to add to the original unoweb: special cards, multiplayer, etc. but, there was a problem:<br/>I had no clue how to efficiently use Flutter and that led to much of the same issues that i'd already had with the original unoweb: it was hard to iterate and fix bugs. i made some pretty stupid architecture choices and literally wrote the entire game in a single file. everything was a map (Dart's version of a JS object) which meant that there was no: type safety, intellisense support within vscode, and high chances for an untraceable bug to enter and ruin everything. at this point, ive had enough. im rewriting this using modern language features like: multiple files, classes, and more!