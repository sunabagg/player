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
        /*try {
            //aboutDialog.popup(Rect2i.fromInts(0, 0, 0, 0));
            //trace(aboutDialog.size.toString());
            //aboutDialog.popupCentered(new Vector2i(184, 100));
        }
        catch (e) {
            trace(e);
        }*/
        var fileMenu = PopupMenu.toPopupMenu(rootElement.find("vbox/menuBarControl/menuBar/File"));
        var helpMenu = PopupMenu.toPopupMenu(rootElement.find("vbox/menuBarControl/menuBar/Help"));
        helpMenu.systemMenuId = 4;
        helpMenu.idPressed.connect((args: ArrayList) -> {
            try {
                var idVar : Variant = untyped __lua__("args[0]");
                trace(idVar == null);
                var id : Int = idVar;
                trace(id);
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