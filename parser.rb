# Example use
# Add project named churchhub
# ruby parser.rb -a project -s churchhub.json -D output.json -w output.json
#
# Add application chrome to project named churchhub
# ruby parser.rb -a application -s chrome.json -D output.json -w output.json -p churchhub
#
# Delete project named dodo
# ruby parser.rb -d project -p dodo -D output.json -w output.json
#
# Delete application from project named dodo
# ruby parser.rb -d application -p dodo -A "Google chrome" D output.json -w output.json 
#
# List all projects
# ruby parser.rb -l 
#
# List project named dodo
# ruby parser.rb -l -p dodo
#
#
#
#
#

require "rubygems"
require "json"
require 'optparse'
require 'oj'


# Option to handle the command 
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: parser.rb [options]"
  opts.on('-a', '--add WHAT', 'Mode add') { |v|
  	options['mode'] = "add" 
  	options['add'] = v
  }
  opts.on('-r', '--run', 'Mode Run') { options['mode'] = "run" }
  opts.on('-d', '--delete WHAT', 'Mode Delete') {|v| 
  	options['mode'] = "delete" 
  	options['delete'] = v
  }
  opts.on('-p', '--project NAME', 'Project') { |v| 
  	options['project'] = v 
  }
  opts.on('-A', '--application NAME', 'Application') { |v| 
  	options['application'] = v 
  }
  opts.on('-D', '--database NAME', 'Source db') { |v| options['source_db'] = v }
  opts.on('-l', '--list', 'List') { options['mode'] = "list" }
  opts.on('-s', '--source FILE', 'Set the source of file') {|v| options['source_file'] = v }
  opts.on('-w', '--write FILE', 'Write to file') { |v|
  	options['write'] = v
  }

end.parse!

if options['source_db']==nil
	options['source_db'] = "data.json"
end

# Instance to handle the Project creation
class Project
    attr_accessor :name, :adddate, :description, :applications, :key

    def initialize(name, description, key)
        @name = name
        @description = description
        @key = key
        @applications = Array.new
    end
end

# Application to handle Application running
class Application
	attr_accessor :name, :type, :category

	def initialize(name,type,category)
		@name = name
		@type = type
		@category = category
	end
end

# Application that is run through command line
class CommandLineApplication < Application
	attr_accessor :working_dir,:start_cmd, :end_cmd
	def initialize(name,type,category,command,working_dir)
		super(name,type,category)
		@working_dir = working_dir
		@start_cmd = command
	end
end

# Application that is run through desktop
class DesktopApplication < Application 
	attr_accessor :location, :documents
	def initialize(name,type,category,location) 
		super(name,type,category)
		@documents = Array.new
		@location = location
	end
end

# Document that need to be run by the application
class Document
	attr_accessor :name, :uri
	def initialize(name,uri)
		@name = name
		@uri = uri
	end
end

# Project profiler to run the project
class ProjectProfiler
    attr_accessor :source, :author, :projects, :createdate

    # Function to readfile
    # return string the content of the file
    def readFile(source)
		counter = 1
		data = ""
		begin
		    file = File.new(source, "r")
		    while (line = file.gets)
		        data = data+line+"\n"
		        counter = counter + 1
		    end
		    file.close
		rescue => err
		    puts "Exception: #{err}"
		    err
		end
		return data
    end

    # Function to initialize the process
    # return void
    def initialize(source)
        @source = source
        @projects = Array.new
        initWithJson()
    end

    # Function to get project based on the key of the project
    # return project instance or null if not found
    def getProject(key)
		@projects.each do |project| 
			if project.key == key	
				return project
			end
		end
		return nil;
    end

    # Function to get application of the project based on its name
    # return application instance or null if not found
    def getApplication(name,project)
		project.applications.each do |app| 
			if app.name == name	
				return app
			end
		end
		return nil;
    end

    # Function to init the instance creation
    # return void
    def initWithJson() 
    	data = readFile(source)
	    j = Oj.load(data)
	    @author = j['author']
	    @createdate = j['createdate']
		@projects = j['projects'].inject([]) do |o,d|
			project =  Project.new(d['name'],d['description'],d['key']) 
			
			project.applications = d['applications'].inject([]) do |app,el2|
				is_cl = el2['type'] == "cl"
				if is_cl
					application = CommandLineApplication.new(el2['name'],el2['type'],el2['category'],el2['command'],el2['working_dir'])
				else 
					application = DesktopApplication.new(el2['name'],el2['type'],el2['category'],el2['location'])
					application.documents = el2['documents'].inject([]) do |doc,el3|
						doc << Document.new(el3['name'],el3['uri'])
					end
				end
				app << application
			end
			o << project
		end
    end

    # Function to run a project based on the key of the project
    # return void
    def runProject(key) 
    	found = false
		@projects.each do |project| 
			if project.key == key	
				found = true
				project.applications.each do |application|
					if application.type == "cl"
						system "echo Running command "+application.name
						if application.working_dir != nil
							system "cd "+application.working_dir
						end
						system application.start_cmd
					else 
						if application.location !=nil
							system "echo Running "+application.name
							if application.documents.length > 0
								application.documents.each do |doc|
									puts "open -n -a #{application.location} \"#{doc.uri}\""
									system "open -n -a #{application.location} \"#{doc.uri}\""
								end
							else
								system "open -n "+application.location
							end							
						end
					end
				end
			end
		end
		if !found
			puts "Project not found"
		end
    end

    # Function to list all available projects
    # return void
    def listOfProjects()
    	@projects.each do |project| 
			listOfApplicationInProject(project.key)
			puts "\n"
		end
    end
    
    # Function to list all application in a project that based on the key of the project
    # return void
    def listOfApplicationInProject(key)
    	p = getProject(key)
		if p == nil
			puts "Project not found"
		else 
			puts p.name << " - #" << p.key 
			puts p.description
			i = 1
			p.applications.each do |app|
				puts "#{i}" << ". " << app.name
				if app.type == "cl"
					if app.working_dir != nil
						puts "Run in "<< app.working_dir
					end
				else
					puts "Documents:"
					app.documents.each do |doc|
						puts "- "<<doc.name<<" ["<<doc.uri+"]"
					end
				end
				
				i = i+1
			end
		end
    end

    # Function to add project to the database
    # return void
    def addProject(project) 
    	@projects << project
    end

    # Function to add application to a project that based on the key of the project
    # return void
    def addApplication(application,key) 
    	project = getProject(key)
    	project.applications << application
    end

    # Function to project from database
    # return void
    def deleteProject(key)
    	project = getProject(key)
		if project == nil
			puts "Project not found"
		else 
			@projects.delete(p)
		end
    end

    # Function to delete application from a project that based on the key of the project
    # return void
    def deleteApplication(app,key)
		project = getProject(key)
		if project == nil
			puts "Project not found"
		else 
			application = getApplication(app,project)
			project.applications.delete(application)
		end
    end

    # Function to end the specified running project
    # return void
    def endProject(key)
    end

    # Function to end all running project
    # return void
    def endAllProjects()
    end    
end




profiler = ProjectProfiler.new(options["source_db"])

if options["mode"] == "run"
	if options["project"] != nil
		profiler.runProject(options["project"])
	else
		puts "You must specify project with this mode"
	end
elsif options["mode"] == "list"
	if options["project"] != nil
		profiler.listOfApplicationInProject(options["project"])
	else
		profiler.listOfProjects()
	end

elsif options["mode"] == "delete"
	if options["delete"] == "project"
		profiler.deleteProject(options["project"])
	elsif options["delete"] == "application"
		profiler.deleteApplication(options["application"],options["project"])
	end
elsif options["mode"] == "end"
	if options["project"] != nil
		profiler.endProject(options["project"])
	else
		profiler.endAllProjects()
	end	
elsif options["mode"] == "add"
	if options["add"] == "project"
		json = profiler.readFile(options["source_file"])
		d = Oj.load(json)
		project =  Project.new(d['name'],d['description'],d['key']) 
		if d['applications'] != nil
			project.applications = d['applications'].inject([]) do |app,el2|
				is_cl = el2['type'] == "cl"
				if is_cl
					application = CommandLineApplication.new(el2['name'],el2['type'],el2['category'],el2['command'],el2['working_dir'])
				else 
					application = DesktopApplication.new(el2['name'],el2['type'],el2['category'],el2['location'])
					application.documents = el2['documents'].inject([]) do |doc,el3|
						doc << Document.new(el3['name'],el3['uri'])
					end
				end
				app << application
			end			
		end
		profiler.addProject(project)
	elsif options["add"] == "application"
		json = profiler.readFile(options["source_file"])
		el2 = Oj.load(json)
		is_cl = el2['type'] == "cl"
		if is_cl
			application = CommandLineApplication.new(el2['name'],el2['type'],el2['category'],el2['command'],el2['working_dir'])
		else 
			application = DesktopApplication.new(el2['name'],el2['type'],el2['category'],el2['location'])
			if el2['documents'] != nil
				application.documents = el2['documents'].inject([]) do |doc,el3|
					doc << Document.new(el3['name'],el3['uri'])
				end
			end
		end
		profiler.addApplication(application,options["project"])
	end					
end

if options["write"] != nil
	json =  Oj::dump profiler, :indent => 2
	File.open(options["write"],"w") do |f|
  		f.write(json)
  		f.close
	end
end
