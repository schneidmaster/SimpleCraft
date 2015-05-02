# SimpleCraft

Toy version of Minecraft written in [three.js](http://threejs.org/) for SIU CS485 Computer Graphics, Spring 2015.

![Screenshot](https://cloud.githubusercontent.com/assets/1896112/7443007/1c96c6cc-f0f1-11e4-9f67-9e5ab7860193.png)

## Usage

1. `git clone git@github.com:schneidmaster/SimpleCraft.git`
2. `npm install` and `bower install`
3. `grunt`
4. `node node_modules/http-server/bin/http-server`
5. Visit [http://localhost:8080](http://localhost:8080)

If you use Firefox, you can skip steps 4 and 5 and just open up `index.html` in your browser. Chrome's same-origin policy requires you to start a server to load the texture files.

## Controls

* Mouse: Move camera
* W, A, S, D: Move
* Space: Jump
* Click: Place new block
* Shift+Click: Destroy block (only dirt can be destroyed)

## Developing

Same steps as under Usage, but run `grunt watch` instead of `grunt` - this will monitor the files and recompile CoffeeScript/rebuild the assets whenever you save a file.

This is a class project, not a true open source project - I probably won't accept non-trivial pull requests. If you want to do something with it feel free to fork.

## License

MIT

## References/Credits

* [three.js FirstPersonControls](https://threejsdoc.appspot.com/doc/three.js/src.source/extras/controls/FirstPersonControls.js.html)
