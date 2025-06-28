package;

import sunaba.App;

class Main extends App {
    public static function main() {
        new App();
    }

    override function init() {
        Sys.println("Hello, World!");
        try {
            var player = new Player();
            rootElement.addChild(player.rootElement);
        } catch (e:Dynamic) {
            trace("Error initializing Player: " + e);
        }
    }
}