require "rubygems"
require "json"
require 'optparse'

# Option to handle the command 
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: parser.rb [options]"
  opts.on('-a', '--add WHAT', 'Mode add') { |v|
  	options['mode'] = "add" 
  	options['add'] = v
  }
  opts.on('-r', '--run', 'Mode Run') { options['mode'] = "run" }
  opts.on('-d', '--delete', 'Mode Delete') { options['mode'] = "delete" }
  opts.on('-p', '--project NAME', 'Project') { |v| 
  	options['project'] = v 
  }
  opts.on('-D', '--database NAME', 'Source db') { |v| options['source_db'] = v }
  opts.on('-l', '--list', 'List') { options['mode'] = "list" }
  opts.on('-s', '--source FILE', 'Set the source of file') { options['source_file'] = "run" }

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
        @adddate = Time.new
        @applications = Array.new
    end

    def to_json()
    	puts name
    	puts description 
    	puts key 
    	puts adddate
    	puts applications.to_json()
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

    def initialize(source)
        @source = source
        @projects = Array.new
        initWithJson()
    end

    def initWithJson() 
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

	    j = JSON.parse(data)
	    @author = j['author']
	    @createdate = j['createdate']
		@projects = j['projects'].inject([]) do |o,d|
			project =  Project.new(d['name'],d['description'],d['key']) 
			
			project.applications = d['applications'].inject([]) do |app,el2|
				is_cl = el2['type'] == "cl"
				if is_cl
					application = CommandLineApplication.new(el2['name'],el2['type'],el2['category'],el2['command'],el2['workingdirectory'])
				else 
					application = DesktopApplication.new(el2['name'],el2['type'],el2['category'],el2['location'])
					application.documents = el2['documents'].inject([]) do |doc,el3|
						doc << Document.new(el3['name'],el3['location'])
					end
				end
				app << application
			end
			o << project
		end
    end
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
							system "open "+application.location				
						end
					end
				end
			end
		end
		if !found
			puts "Project not found"
		end
    end

    def listOfProjects()
    	@projects.each do |project| 
			listOfApplicationInProject(project.key)
			puts "\n"
		end
    end
    
    def listOfApplicationInProject(key)
    	found = false
    	p = nil
		@projects.each do |project| 
			if project.key == key	
				found = true
				p = project
			end
		end
		if !found
			puts "Project not found"
		else 
			puts p.name
			puts p.description
			puts p.key 
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

    def addProject(project) 
    	@projects << project
    end

    def deleteProject(key)
    	found = false
    	p = nil
		@projects.each do |project| 
			if project.key == key	
				found = true
				p = project
			end
		end
		if !found
			puts "Project not found"
		else 
			@projects.delete(p)
		end
    end

    def endProject(key)
    end

    def endAllProject()
    end    
end




profiler = ProjectProfiler.new(options["source_db"])

if options["mode"] == "run"
	if options["project"] != nil
		profiler.runProject(options["project"])
	else

	end
elsif options["mode"] == "list"
	if options["project"] != nil
		profiler.listOfApplicationInProject(options["project"])
	else
		profiler.listOfProjects()
	end

elsif options["mode"] == "delete"
	if options["project"] != nil
		profiler.deleteProject(options["project"])
	else
		
	end
elsif options["mode"] == "end"
	if options["project"] != nil
		profiler.endProject(options["project"])
	else
		
	end					
end