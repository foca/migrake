# Migrake

[![Build Status](https://secure.travis-ci.org/foca/migrake.png?branch=master)](http://travis-ci.org/foca/migrake)

A simple [Rake][rake] extension that lets you define tasks that are divided into
multiple smaller "versions". When you run the task in a given host, it will only
run the "versions" that haven't yet been run in that host. Think something
similar to [ActiveRecord::Migration][migrations] for Rake tasks.

This is specially useful to define tasks that should be run on deploy, in order
to do some sort of house cleaning that should be run once. For example, some
complex data migrations, or re-processing your user avatars because now the UI
shows them in a different size.

The important thing is these tasks should only be run once when you deploy to a
given environment, and they should be run immediately.

[rake]:       http://rake.rubyforge.org
[migrations]: http://api.rubyonrails.org/classes/ActiveRecord/Migration.html

## An example

In `lib/tasks/migrake.rake`:

``` ruby
require "migrake"

migrake Set.new([
  "data:set_default_user_state",
  "twitter:purge_cache",
  # etc, etc
])
```

This would define a task called `:migrake` that, when called, will invoke the
tasks in that set _unless they have been invoked before_. This means that after
each deploy you can run this task (with a capistrano hook, for example) and any
tasks that need to be run in this environment will be run.

## How it works

This will keep a file named `MIGRAKE_STATUS`, that will contain the name of the
tasks that were ran in the past. Whenever you run `rake migrake` migrake will
check that file, see which tasks in the set aren't in it, and will run those
tasks (no order is guaranteed, if you need tasks to run in order, define the
dependencies in the task themselves.)

## Overriding the file where tasks are stored

The file will be located, by default, at whichever directory `rake` is invoked
from. In order to change the path to the file, you can do this:

``` ruby
Migrake.store = Migrake::FileSystemStore.new("./config/migrake")
```

This *must* be called in your Rakefile before you define the tasks to be run by
`migrake`. Like this:

``` ruby
require "migrake"

Migrake.store = Migrake::FileSystemStore.new("./config/migrake")

migrake Set.new([
  # ...
])
```

As an alternative, you can make `MIGRAKE_STATUS_DIR` available to your
environment, and migrake will use a `MIGRAKE_STATUS` file in that directory.

``` shell
MIGRAKE_STATUS_DIR=./some/path bundle exec rake migrake
```

This is particularly useful to use with capistrano, since you probably want to
use cap's `shared` directory to store your migrake file. For example:

``` ruby
namespace :deploy do
  task :migrake do
    run "MIGRAKE_STATUS_DIR=#{shared_path} bundle exec rake migrake"
  end
end

after "deploy:migrations", "deploy:migrake"
```

## Bootstrapping a new environment

When you bootstrap a new environment you don't need to run migrake tasks that
have been already run. For this, when the `migrake` method is invoked we also
define a `migrake:ready` task, that forces all tasks defined in the migrake set
into the `MIGRAKE_STATUS` file.

This way you can just run that when you bootstrap the environment and then keep
running `rake migrake` when you deploy.

## License

(The MIT License)

Copyright (c) 2012 [Nicolas Sanguinetti][me], with the support of [Cubox][cubox]

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[me]:    http://nicolassanguinetti.info
[cubox]: http://cuboxlabs.com
