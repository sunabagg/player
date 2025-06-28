package;


class Main {
    public static function main() {
        Sys.println("Hello, World!");

        var tsukuru = new Tsukuru();
        tsukuru.zipOutputPath = "./template/player.sbx";
        tsukuru.build("./player.snbproj");
    }
}