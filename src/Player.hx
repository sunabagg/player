package;

import sunaba.ui.Widget;
import sunaba.desktop.AcceptDialog;
import sunaba.core.Vector2i;
import sunaba.core.Rect2i;
import sunaba.desktop.PopupMenu;
import sunaba.desktop.FileDialog;
import sunaba.core.ArrayList;
import sunaba.core.Variant;
import sunaba.FileDialogMode;
import sunaba.core.SubViewport;

class Player extends Widget {
    var subViewport: SubViewport;

    override function init() {
        load("app://Player.suml");

        subViewport = SubViewport.toSubViewport(rootElement.find("vbox/gameView/subViewportContainer/subViewport"));

        var aboutDialog : AcceptDialog = AcceptDialog.toAcceptDialog(rootElement.find("aboutDialog"));
        buildAboutDialog(aboutDialog);
        var fileMenu = PopupMenu.toPopupMenu(rootElement.find("vbox/menuBarControl/menuBar/File"));
        fileMenu.idPressed.connect((args: ArrayList) -> {
            var id = args.get(0).toInt();
            trace(id);
            if (id == 0) {
                var fileDialog = new FileDialog();
                fileDialog.fileMode = FileDialogMode.openFile;
                fileDialog.useNativeDialog = true;
                fileDialog.access = 2;
                fileDialog.title = "Open Sunaba Game";
                fileDialog.addFilter("*.sbx", "Sunaba Game");
                rootElement.addChild(fileDialog);

                fileDialog.fileSelected.connect((args: ArrayList) -> {
                    var path = args.get(0).toString();
                    fileDialog.hide();
                    fileDialog.delete();
                    openSbx(path);
                });

                fileDialog.popupCentered(new Vector2i(0, 0));
            }
            else if (id == 1) {
                untyped __lua__("_G.exit()");
            }
        });
        var helpMenu = PopupMenu.toPopupMenu(rootElement.find("vbox/menuBarControl/menuBar/Help"));
        helpMenu.systemMenuId = 4;
        helpMenu.idPressed.connect((args: ArrayList) -> {
            var id = args.get(0).toInt();
            if (id == 0) {
                var scaleFactor = aboutDialog.contentScaleFactor;
                var scaleFactorInt = Math.round(scaleFactor);
                aboutDialog.popupCentered(new Vector2i(300 * scaleFactorInt, 123 * scaleFactorInt));
            }
        });
    }

    function buildAboutDialog(dialog: AcceptDialog) {
        var aboutString = "Sunaba Player\n";
        aboutString += "Version 0.7.0\n";
        aboutString += "(C) 2022-2025 mintkat\n";
        dialog.dialogText = aboutString;
    }

    function openSbx(path: String) {
        trace(path);
    }
}