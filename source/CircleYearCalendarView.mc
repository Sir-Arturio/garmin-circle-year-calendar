import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Math;

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

        var offsetRad = -0.5 * Math.PI;
        var offsetDays = 21;
        var directionClockwise = false;

        var calendarModel = new CircleYearCalendarModel(currentDayMoment, offsetRad, offsetDays, directionClockwise);
        var calculatedMonths = calendarModel.calculateMonths();
        var calculatedCurrentDay = calendarModel.calculateCurrentDay();

        var drawHelper = new DrawHelper(dc, 10);
        drawHelper.drawMonthArcs(calculatedMonths, self.getMonthColors());
        drawHelper.drawMonthDividers(calculatedMonths);
        drawHelper.drawCurrentDay(calculatedCurrentDay);
    }

    // Get month colors.
    function getMonthColors() {
        var monthColors = [];
        monthColors.add(Graphics.COLOR_BLUE);
        monthColors.add(Graphics.COLOR_BLUE);
        monthColors.add(Graphics.COLOR_GREEN);
        monthColors.add(Graphics.COLOR_GREEN);
        monthColors.add(Graphics.COLOR_GREEN);
        monthColors.add(Graphics.COLOR_DK_GREEN);
        monthColors.add(Graphics.COLOR_DK_GREEN);
        monthColors.add(Graphics.COLOR_YELLOW);
        monthColors.add(Graphics.COLOR_ORANGE);
        monthColors.add(Graphics.COLOR_ORANGE);
        monthColors.add(Graphics.COLOR_BLUE);
        monthColors.add(Graphics.COLOR_RED);
        return monthColors;
    }
}
