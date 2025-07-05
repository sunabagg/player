package;


class Main {
    static var godot_command = "godot";

    public static function main() {
        var args = Sys.args();

        var currentDir = Sys.getCwd();
        trace(currentDir);
        if (StringTools.contains(currentDir, "\\"))
            currentDir = StringTools.replace(currentDir, "\\", "/");

        var tsukuru = new Tsukuru();
        tsukuru.zipOutputPath = currentDir + "template/player.sbx";
        tsukuru.build(currentDir + "player.snbproj");


        for (i in 0...args.length) {
            var arg = args[i];
            if (StringTools.startsWith(arg, "--godot-command=")) {
                godot_command = StringTools.replace(arg, "--godot-command=", "");
                Sys.println("Using godot command: " + godot_command);
            }
        }

        if (args[0] == "run") {
            run();
            return;
        }
    }

    public static function run() {
        var result = Sys.command(godot_command + " --path ./template");
        Sys.exit(result);
    }
}