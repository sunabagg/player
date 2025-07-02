package;

import sunaba.ui.Widget;
import sunaba.desktop.AcceptDialog;
import sunaba.core.Vector2i;
import sunaba.core.Rect2i;
import sunaba.desktop.PopupMenu;
import sunaba.core.ArrayList;
import sunaba.core.Variant;

class Player extends Widget {
    override function init() {
        load("app://Player.suml");
        var aboutDialog : AcceptDialog = AcceptDialog.toAcceptDialog(rootElement.find("aboutDialog"));
        buildAboutDialog(aboutDialog);
        var fileMenu = PopupMenu.toPopupMenu(rootElement.find("vbox/menuBarControl/menuBar/File"));
        var helpMenu = PopupMenu.toPopupMenu(rootElement.find("vbox/menuBarControl/menuBar/Help"));
        helpMenu.systemMenuId = 4;
        helpMenu.idPressed.connect((args: ArrayList) -> {
            try {
                trace(args == null);
                var idVar : Variant = args.get(0);
                trace(idVar == null);
                var id : Int = idVar.toInt();
                if (id == 0) {
                    var scaleFactor = aboutDialog.contentScaleFactor;
                    var scaleFactorInt = Math.round(scaleFactor);
                    aboutDialog.popupCentered(new Vector2i(300 * scaleFactorInt, 123 * scaleFactorInt));
                }
            }
            catch(e) {
                trace(e);
            }
        });
    }

    function buildAboutDialog(dialog: AcceptDialog) {
        var aboutString = "Sunaba Player\n";
        aboutString += "Version 0.7.0\n";
        aboutString += "(C) 2022-2025 mintkat\n";
        dialog.dialogText = aboutString;
    }
}