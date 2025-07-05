package;
import sys.FileSystem;


enum abstract ExportType(String) from String to String {
    var release = "release";
    var debug = "debug";
}

class Main {
    static var godotCommand = "godot";

    static var targetPlatform = "";

    static var exportType = ExportType.debug;

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
                godotCommand = StringTools.replace(arg, "--godot-command=", "");
                Sys.println("Using godot command: " + godotCommand);
            }
            else if (StringTools.startsWith(arg, "--target=")) {
                targetPlatform = StringTools.replace(arg, "--target=", "");
            }
            else if (arg == "-debug") {
                exportType = ExportType.debug;
            }
            else if (arg == "-release") {
                exportType = ExportType.release;
            }
        }

        trace("exportType == ExportType.debug: " + exportType == ExportType.debug);
        trace("exportType == ExportType.release: " + exportType == ExportType.release);

        if (args[0] == "run") {
            run();
            return;
        }
        else if (args[0] == "export") {
            export();
        }
    }

    public static function run() {
        var result = Sys.command(godotCommand + " --path ./template");
        Sys.exit(result);
    }

    public static function export() {
        if (targetPlatform == "") {
            var systemName =  Sys.systemName();
            if (systemName == "Windows") {
                targetPlatform = "windows-amd64";
            }
            else if (systemName == "Mac") {
                targetPlatform = "mac-universal";
            }
            else if (systemName == "Linux") {
                targetPlatform = "linux-amd64";
            }
        }
        var targetName: String = "";
        if (targetPlatform == "mac-univeral") {
            targetName = "Sunaba Player.app";
        }
        else if (targetPlatform == "windows-amd64") {
            targetName = "SunabaPlayer.exe";
        }
        else if (targetPlatform == "linux-amd64") {
            targetName = "sunaba-player";
        }
        else {
            Sys.println("Invalid target: " + targetPlatform);
            Sys.exit(-1);
        }

        Sys.println("Exporting for target platform: " + targetPlatform);
        Sys.println("Exporting for " + exportType);

        var rootPath = Sys.getCwd() + "bin";
        if (!FileSystem.exists(rootPath)) {
            FileSystem.createDirectory(rootPath);
        }

        var targetPath = rootPath + "/" + targetPlatform + "-" + exportType;
        if (!FileSystem.exists(targetPath)) {
            FileSystem.createDirectory(targetPath);
        }



        var command = godotCommand + " --path ./template --headless --editor --export-" + exportType + " \"" + targetPlatform + "\" \"../bin/" + targetPlatform + "-" + exportType + "/" + targetName + "\"";
        //trace(command);

        var result = Sys.command(command);
        if (result != 0) {
            Sys.println(godotCommand + " exited with code " + result);
            Sys.exit(result);
        }
    }
}