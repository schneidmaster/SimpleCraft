# SimpleCraft

Toy version of Minecraft written in three.js for SIU CS485 Computer Graphics, Spring 2015.

Currently under development and not yet functional.

## Usage

1. `git clone git@github.com:schneidmaster/SimpleCraft.git`
2. `npm install` and `bower install`
3. `grunt`
4. `node node_modules/http-server/bin/http-server`
5. Visit [http://localhost:8080](http://localhost:8080)

## Controls

* W, A, S, D: Move
* Space: Jump
* Click: Place new block
* Shift+Click: Destroy block (only dirt can be destroyed)

## Developing

Same steps as under Usage, but run `grunt watch` instead of `grunt` - this will monitor the files and recompile CoffeeScript/rebuild the assets whenever you save a file.

This is a class project, not a true open source project - I probably won't accept non-trivial pull requests. If you want to do something with it feel free to fork.

## License

MIT