import Toybox.Lang;
import Toybox.WatchUi;

class CircleYearCalendarDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new CircleYearCalendarMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}