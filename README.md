# Dude

Dude is a DSL in ruby which helps to painfully ease your migration of workstation or clean installs.
`Credit` goes to `github.com/opscode/chef` for providing code to build CLI's faster. 

This uses mixlib-cli, mixlib-config, mixlib-log, mixlib-auth.

### Requirements

Ruby 2.0.0.p0 preferred; 1.9.3+ required 


#### Runtime Rubygem Dependencies

First you'll need [bundler](http://github.com/carlhuda/bundler) which can
be installed with a simple `gem install bundler`. Afterwords, do the following:

    bundle install

### Installing Dude

You can use this gem by putting the following inside your Gemfile:

    gem install dude


### Commands

```ruby
	Dude	-h
	Usage: dude (options)
    -i, --install INSTALL            The installation file path to use (required)
    -V, --verbose                    More verbose output. Use twice for max verbosity
    -v, --version                    Show dude version
    -y, --yes                        Say yes to all prompts for confirmation
    -h, --help                       Show this message
```

## Usage

## Conventions

> you  : This is your Home directory
> root : This is your Root directory

### Prepare your work area

Let us say you want to clone the current system and install the same in system X.


 > Create a backup directory
 > Create a dsl in ruby named dsl.rb. You can call it the way you want.
 > Run dude. as follows, assuming that your backup directory resides in ~, where ~ is your <home>

```
  dude -i ~\backup\dsl.rb
```

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
### Creating your DSL

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

### Warning :
Read my [blog.megam.co](http://blog.megam.co/archives/485) for more info.

# License

Dude - A toolset to ease workstation installs.
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
