package;

import sunaba.ui.Button;
import sunaba.ui.Button.ButtonAbstract;
import sunaba.ui.Label;
import sunaba.ui.Widget;

class Player extends Widget {
    var label: Label;
    var counter: Int = 0;
    
    override function init() {
        load("app://assets/Player.suml");
        var labelElement = rootElement.find(
            "centerContainer/vboxContainer/clickCounterLabel"
        );
        if (labelElement.isNull()) {
            throw "Label element not found in Player layout.";
        }
        label = Label.toLabel(
            labelElement
        );
        var buttonA : ButtonAbstract = rootElement.find(
            "centerContainer/vboxContainer/clickerButton"
        );
        var button : Button= buttonA;
        button.pressed.connect(() -> {
            onClick();
        });
    }

    function onClick() {
        counter++;
        if (label != null) {
            label.text = "You clicked me " + counter + " times!";
        }
    }
}