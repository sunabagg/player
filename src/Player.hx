package;

import sunaba.ui.Widget;
import sunaba.desktop.AcceptDialog;
import sunaba.core.Vector2i;
import sunaba.core.Vector2;
import sunaba.core.Rect2i;
import sunaba.desktop.PopupMenu;
import sunaba.desktop.FileDialog;
import sunaba.core.ArrayList;
import sunaba.core.Variant;
import sunaba.FileDialogMode;
import sunaba.core.SubViewport;
import sunaba.Runtime;
import sunaba.App;
import sunaba.core.PlatformService;
import sunaba.core.DeviceType;
import sunaba.input.InputEvent;
import sunaba.input.InputService;
import sunaba.Key;
import sunaba.ui.Control;
import sunaba.WindowMode;

class Player extends Widget {
    var subViewport: SubViewport;
    var runtime: Runtime = null;

    var menuBarControl: Control;

    override function init() {
        load("app://Player.suml");

        var args = Sys.args();
        var sbxPath = "";
        for (arg in args) {
            if (StringTools.endsWith(arg, ".sbx") && sbxPath == "") {
                sbxPath = arg;
            }
        }

        subViewport = SubViewport.toSubViewport(rootElement.find("vbox/gameView/subViewportContainer/subViewport"));

        var aboutDialog : AcceptDialog = AcceptDialog.toAcceptDialog(rootElement.find("aboutDialog"));
        buildAboutDialog(aboutDialog);

        menuBarControl = Control.toControl(rootElement.find("vbox/menuBarControl"));
        if (PlatformService.osName == "macOS") {
            menuBarControl.customMinimumSize = new Vector2(0, 0);
        }

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
                App.exit();
            }
        });

        var viewMenu = PopupMenu.toPopupMenu(rootElement.find("vbox/menuBarControl/menuBar/View"));
        if (PlatformService.osName == "macOS") {
            viewMenu.removeItem(1); // Remove "Menu Bar" item on macOS
            viewMenu.setItemText(0, "Toggle Fullscreen (Cmd+F)");
        }
        viewMenu.idPressed.connect((args: ArrayList) -> {
            var id = args.get(0).toInt();
            if (id == 0) {
                toggleFullscreen();
            }
            else if (id == 1) {
                toggleMenuBar();
            }
        });

        var helpMenu = PopupMenu.toPopupMenu(rootElement.find("vbox/menuBarControl/menuBar/Help"));
        if ((PlatformService.deviceType == DeviceType.desktop) && (PlatformService.osName != "Windows")) {
            helpMenu.systemMenuId = 4;
        }
        helpMenu.idPressed.connect((args: ArrayList) -> {
            var id = args.get(0).toInt();
            if (id == 0) {
                var scaleFactor = aboutDialog.contentScaleFactor;
                var scaleFactorInt = Math.round(scaleFactor);
                aboutDialog.popupCentered(new Vector2i(300 * scaleFactorInt, 123 * scaleFactorInt));
            }
        });

        if (sbxPath != "" && StringTools.endsWith(sbxPath, ".sbx")) {
            openSbx(sbxPath);
        }
    }

    function buildAboutDialog(dialog: AcceptDialog) {
        var aboutString = "Sunaba Player\n";
        aboutString += "Version 0.7.0\n";
        aboutString += "(C) 2022-2025 mintkat\n";
        aboutString += "\n";

        aboutString += "OS: " + PlatformService.osName + "\n";
        var deviceTypeStr = "Unknown";
        if (PlatformService.deviceType == DeviceType.desktop) {
            deviceTypeStr = "Desktop";
        }
        else if (PlatformService.deviceType == DeviceType.mobile) {
            deviceTypeStr = "Mobile";
        }
        else if (PlatformService.deviceType == DeviceType.web) {
            deviceTypeStr = "Web";
        }
        else if (PlatformService.deviceType == DeviceType.xr) {
            deviceTypeStr = "XR";
        }
        aboutString += "Device Type: " + deviceTypeStr + "\n";

        dialog.dialogText = aboutString;
    }

    function input(inpueEvent: InputEvent) {
        trace("Input");
        if (PlatformService.osName != "macOS") {
            if (InputService.isKeyLabelPressed(Key.ctrl) && InputService.isKeyLabelPressed(Key.f1)) {
                trace("Escape key Pressed");
                App.exit();
            }
            if (InputService.isKeyLabelPressed(Key.f2)) {
                trace("F2 key Pressed");
                toggleMenuBar();
            }
            if (InputService.isKeyLabelPressed(Key.f11)) {
                toggleFullscreen();
            }
        }
        else {
            if (InputService.isKeyLabelPressed(Key.meta) && InputService.isKeyLabelPressed(Key.f)) {
                toggleFullscreen();
            }
            if (InputService.isKeyLabelPressed(Key.meta) && InputService.isKeyLabelPressed(Key.q)) {
                App.exit();
            }
        }
    }

    function toggleMenuBar() {
        menuBarControl.visible = !menuBarControl.visible;
    }

    function toggleFullscreen() {
        var window = rootElement.getWindow();
        if (window.mode != WindowMode.fullscreen) {
            window.mode = WindowMode.fullscreen;
        }
        else {
            window.mode = WindowMode.windowed;
        }
    }

    function openSbx(path: String) {
        trace(path);
        try {
            if (runtime != null) {
                runtime.delete();
                runtime = null;
            }
            runtime = new Runtime();
            subViewport.addChild(runtime);
            runtime.init();
            runtime.load(path);
        }
        catch (e) {
            trace(e);
        }
    }
}