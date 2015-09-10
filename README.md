# Project Profiler

## Introduction
Have lots of project that requires loading all of the program and files? Feel dizzy when you need to reopen or switch those projects again and again? This project is about to make your project management a little bit easier. You just need to open or close the desired project and all of the program will otomatically does all the things you want.

## How it works
1. You create a project or a state where you want a set of applications to run at the same time
2. Register all the applications that you want to use when working with the project
3. At any given of time, start any project you desired to work at, all those program you registered before will run
4. You can also register a console script

## How to use:

1. Add project named churchhub
  
  `ruby parser.rb -a project -s churchhub.json [-D output.json -w output.json]`

2. Add application chrome to project named churchhub
  
  `ruby parser.rb -a application -s chrome.json [-D output.json -w output.json] -p churchhub`

3. Delete project named dodo
  
  `ruby parser.rb -d project -p dodo [-D output.json -w output.json]`

4. Delete application from project named dodo
  
  `ruby parser.rb -d application -p dodo -A "Google chrome" [D output.json -w output.json]` 

5. List all projects  
   
  `ruby parser.rb -l`

6. List project named dodo
  
  `ruby parser.rb -l -p dodo`

`[]` means optional.

## Contributing
The requirement that needed to start contributing is simple. A set of unix-like computer with ruby installed in it. 

Please not that the ruby script is a little part of the big picture. Its roles is to communicate with database (the json file) and the system console. In addition of this script, we need to make a GUI so any common user can use it for their daily activities such as for Studying, Working, Drawing, Watching, etc. 

Idea for the development is welcomed as this program isn't even used avidly by me. Yet.
