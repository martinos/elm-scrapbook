# Elm 0.16 Migration of Simple App

Once 0.16 [installed](http://elm-lang.org/install])

Installing my app's packages didn't work

    elm package install

I got the following message

```
Error: Error reading file elm-package.json:
    Problem with the `repository` field.

Upper case characters are not allowed in package names
```

I think it would be easier just to delete the [elm-package.json](https://gist.github.com/c89634bddcdda86038c4) file and add back all  packages.
```
elm package install elm-lang/core
elm package install evancz/elm-html
elm package install evancz/elm-http
elm package install evancz/elm-markdown
elm package install evancz/start-app
```

I tried to build my program

    elm make new_stories.elm

I got the following message

```
Success! Compiled 10 modules.
elm-make: elm-stuff/build-artifacts/0.16.0/evancz/virtual-dom/2.1.0/VirtualDom.elmo: openFile: does not exist (No such file or directory)
```

Maybe we should clean everything

```
rm -rf elm-stuff
elm make new_stories.elm
```
[Here](https://gist.github.com/490b97b0e7d106b2aec1) is the output

Good, we're a bit closer

If curious and want to see what has changed in the `elm-package.json` file. Go [here](https://gist.github.com/martinos/09cb696c3db634c00cf0)

We can see that the record assignment syntax has changed

```
I ran into something unexpected when parsing your code!

105│             { game | past <- game.now :: game.past
                               ^
I am looking for one of the following things:

    an equals sign '='
    whitespace
```

The message is quite explicit.  I correct the source.

```
$ elm make new_stories.elm
Success! Compiled 1 modules.
Successfully generated index.html
```
Cool, migration completed.
