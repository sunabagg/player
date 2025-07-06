package;
import sys.FileSystem;
import sys.io.File;

class Main {
    static var godotCommand = "godot";

    static var targetPlatform = "";

    static var exportType = ExportType.debug;

    static var packageFormat = PackageFormat.none;

    public static function main() {
        var args = Sys.args();

        if (args[0] == "-h" || args[0] == "--help") {
            Sys.println("Usage: node build [run|export] [--godot-command=<command>] [--target=<platform>] [-debug|-release]");
            Sys.println("  run: Run the Sunaba Player");
            Sys.println("  --godot-command=<command>: Specify the Godot command to use (default: godot)");
            Sys.println("  export: Export the Sunaba Player for the specified platform");
            Sys.println("  --godot-command=<command>: Specify the Godot command to use (default: godot)");
            Sys.println("  --target=<platform>: Specify the target platform (default: auto-detect based on OS)");
            Sys.println("  -debug: Export in debug mode");
            Sys.println("  -release: Export in release mode");
            return;
        }

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
            else if (StringTools.startsWith(arg, "--pkgformat=")) {
                var format = StringTools.replace(arg, "--pkgformat=", "");
                if (format != "") {
                    if (format == "nsis") {
                        packageFormat = PackageFormat.nsis;
                    }
                }
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

        if (packageFormat == PackageFormat.nsis) {
            buildNsisInstaller();
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
        if (targetPlatform == "mac-universal") {
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
            trace("Godot export failed with code " + result);
            Sys.println(godotCommand + " exited with code " + result);
            Sys.exit(result);
        }
    }

    public static function buildNsisInstaller() {
        var nsisCommand = "makensis";
        if (Sys.systemName() == "Windows") {
            if (Sys.command(nsisCommand + " /VERSION") != 0) {
                Sys.println("NSIS is not installed or not found in PATH.");
                Sys.exit(-1);
            }
        }
        else if (Sys.systemName() == "Linux" || Sys.systemName() == "Mac") {
            nsisCommand = "makensis";
            if (Sys.command(nsisCommand + " -VERSION") != 0) {
                Sys.println("NSIS is not installed or not found in PATH.");
                Sys.exit(-1);
            }
        }

        var outputInstallerPath = Sys.getCwd() + "bin/" + targetPlatform + "-" + exportType + "-nsis/SunabaPlayerInstaller.exe";

        if (!FileSystem.exists(Sys.getCwd() + "/bin/" + targetPlatform + "-" + exportType + "-nsis")) {
            FileSystem.createDirectory(Sys.getCwd() + "/bin/" + targetPlatform + "-" + exportType + "-nsis");
        }

        var nsisScript = "setup.nsi";
        if (exportType == ExportType.debug) {
            nsisScript = "setup-debug.nsi";
        }

        var command = nsisCommand + " " + nsisScript;
        trace("Running NSIS command: " + command);
        var result = Sys.command(command);
        if (result != 0) {
            Sys.println("NSIS installer creation failed with code " + result);
            Sys.exit(result);
        }

        Sys.println("NSIS installer created at: " + outputInstallerPath);
    }

    public static function createDebPackage() {
        var cwd = Sys.getCwd();

        if (!StringTools.endsWith(cwd, "/")) {
            cwd += "/";
        }

        var debRootPath = cwd + ".debian/";
        if (!FileSystem.exists(debRootPath)) {
            FileSystem.createDirectory(debRootPath);
        }

        var debPackagePath = debRootPath + "sunaba-player_" + exportType + "/";
        if (!FileSystem.exists(debPackagePath)) {
            FileSystem.createDirectory(debPackagePath);
        }

        var debUsrPath = debPackagePath + "usr/";
        if (!FileSystem.exists(debUsrPath)) {
            FileSystem.createDirectory(debUsrPath);
        }

        buildUnixDir(debUsrPath);

        var debDebianPath = debPackagePath + "DEBIAN/";
        if (!FileSystem.exists(debDebianPath)) {
            FileSystem.createDirectory(debDebianPath);
        }


    }

    public static function buildUnixDir(path: String) {
        var rootPath = Sys.getCwd() + "bin";
        var exportPath = rootPath + "/" + targetPlatform + "-" + exportType + "/";

        if (!StringTools.endsWith(path, "/")) {
            path += "/";
        }

        var binPath = path + "bin/";
        var libPath = path + "lib/";
        var sharePath = path + "share/";
        var shareSunabaPath = sharePath + "sunaba/";

        if (!FileSystem.exists(binPath)) {
            FileSystem.createDirectory(binPath);
        }
        if (!FileSystem.exists(libPath)) {
            FileSystem.createDirectory(libPath);
        }
        if (!FileSystem.exists(sharePath)) {
            FileSystem.createDirectory(sharePath);
        }
        if (!FileSystem.exists(shareSunabaPath)) {
            FileSystem.createDirectory(shareSunabaPath);
        }

        var executableName = "sunaba-player";
        File.copy(exportPath + executableName, binPath + executableName);

        var libraryName = "libsunaba.so";
        if (exportType == ExportType.debug) {
            libraryName = "libsunaba-d.so";
        }
        File.copy(exportPath + libraryName, libPath + libraryName);

        for (file in FileSystem.readDirectory(exportPath)) {
            if (StringTools.contains(file, executableName) || StringTools.contains(file, libraryName)) {
                continue;
            }
        }
    }
}