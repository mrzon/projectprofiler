# projectprofiler
Have lots of project that requires loading all of the program and files? Feel dizzy when you need to reopen or switch those projects again and again? This project is about to make your project management a little bit easier. You just need to open or close the desired project and all of the program will otomatically does all the things you want.

How to use:

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
