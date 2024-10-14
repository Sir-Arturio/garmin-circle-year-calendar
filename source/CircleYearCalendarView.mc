import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;

class CircleYearCalendarView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var currentDayMoment = new Time.Moment(Time.now().value());

        var calendarModel = new CircleYearCalendarModel(currentDayMoment);
        var calculatedMonths = calendarModel.calculateMonths();
        var calculatedCurrentDay = calendarModel.calculateCurrentDay();

        var drawHelper = new DrawHelper(dc);
        drawHelper.drawMonths(calculatedMonths);
        drawHelper.drawCurrentDay(calculatedCurrentDay);
    }
}
