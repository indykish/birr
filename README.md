# Birr

Birr is a DSL in ruby which helps to painfully ease setting up of your workstation from a clean state.
You can create dynamic scripting at a rapid pace.

`Credit` goes to `github.com/opscode/chef` for providing code to build CLI's faster. 

This uses mixlib-cli, mixlib-config, mixlib-log, mixlib-auth.

### Requirements

Ruby 2.0.0.p0 preferred; 1.9.3+ required 


#### Platforms

`*linux` platform. Extensively tested on `Ubuntu 12.10, 13.04` & `Ruby 2.0`

### Installing Birr

You can use this gem by running :

    gem install birr


### Commands

```ruby
	Birr	-h
	Usage: Birr (options)
    -i, --install INSTALL            The installation file path to use (required)
    -V, --verbose                    More verbose output. Use twice for max verbosity
    -v, --version                    Show Birr version
    -y, --yes                        Say yes to all prompts for confirmation
    -h, --help                       Show this message
```

## Usage

### Conventions

> you  : This is your Home directory and is figured out from the ENV[HOME] variable
> root : This is your Root directory, defaults to '/'

The directory can be given as

let us say your `ENV[HOME]` is `/home/ram` 

	> `you`      means ~      (or) `/home/ram` 
	> `you.bin'  means ~/bin  (or) `/home/ram/bin`

You have noticed above that the File::SEPARATOR is "." and its gets converted by `birr` automagically.

### Prepare your work area

Let us say you want to clone the current system and install the same in system X.


 > Create a backup directory
 > Create a dsl in ruby named dsl.rb. You can call it the way you want.
 > Run Birr. as follows, assuming that your backup directory resides in ~, where ~ is your <home>

```  
Birr -i ~\backup\dsl.rb  
```
### What goes into your backup\ directory 

This is a sample.

```
 backup\
   |
   *-dsl.rb
   |
   *--dump\
   |
   *-------you\<your files that you want to copy> 
   |
   *-------root\<your root files that you want to copy> 
   |
   *--package\
   |
   *-------script\rails\rails.sh 
   |
   *-------script\script\chef.sh
   |
   *--tarball\
   |
   *-------you\bin\eclipse.tar.gz 
   |
   *-------you\bin\software\apache\tomcat.tar.gz
```
### Creating your own DSL [dsl.rb]

```ruby
   
class DSL
  include  Megam::Install

  #just do a massive copy of your home backup files into your new home.
  dump :directory=>"you" do
  end

  #this will install openjdk
  install :message => "Installing OpenJDK" do
    command ["sudo apt-get install -y openjdk-7-jdk"]
  end

  #this will kickoff a script named rails.sh in rails directory
  script :message =>"Installing Rails", :directory => "rails" do
    command  ["rails.sh"]
  end

 
  #this will untar a file named eclipse.tar.gz from the tarball package into home/bin dir
  tarball :message => "Installing Eclipse",:directory => "you.bin" do
    tarball "eclipse.tar.gz"
    command ["untar"]
  end
end                     
```

### Packaging a gem

There is a rake task which let us to build a GEM and test it locally. 
[How to package a gem](http://rubylearning.com/blog/how-do-i-create-and-publish-my-first-ruby-gem/) 
seems to be a pretty good link.

```ruby
cd Birr

rake clean

rm -r pkg

rake package

gem push Birr-<VERSION>.gem
```


### Warning :
Read my [blog.megam.co](http://blog.megam.co/archives/485) for more info.

TO-DO : > A shell command timesout and causes the program to exit pre-maturely.
        > Looking for a better replacement to mixlib-shell, which allows the stdouts to be shown as and when it arrives.
        > Support for more levels of when the directory is referenced (eg: you.software.apache)
        > Synch to a network
        > Integration with backup utilities
          
# License

Birr - A toolset to ease repetitive workstation installs.
Read the [blog.megam.co](http://blog.megam.co/archives/485) for more info.

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | Kishorekumar (<megam@megam.co.in>)
| **Copyright:**       | Copyright (c) 2012-2013 Megam Systems.
| **License:**         | Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
