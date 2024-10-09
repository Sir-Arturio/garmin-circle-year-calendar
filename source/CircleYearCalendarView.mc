import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;
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

        var calendarModel = new CircleYearCalendarModel(currentDayMoment);
        var calculatedMonths = calendarModel.calculateMonths();
        var calculatedCurrentDay = calendarModel.calculateCurrentDay();

        drawMonths(dc, calculatedMonths);
        drawCurrentDay(dc, calculatedCurrentDay);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // Draw the months.
    function drawMonths(dc as Dc, months as Lang.Array) {
        for (var i = 0; i < 12; i++) {
            drawMonth(dc, months[i]);
        }
    }

    // Draw the current day.
    function drawCurrentDay(dc as Dc, dayPoint as Lang.Dictionary) {
        // If the width and height are different, use the lowest to calculate the maximum line size.
        var maxLineSize = (dc.getWidth() < dc.getHeight()) ? dc.getWidth() : dc.getHeight();
        maxLineSize = maxLineSize / 2;

        // Calculate the center point.
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;

        var drawableCirclePoint =  calculateDrawableCirclePoint(centerX, centerY, maxLineSize, dayPoint);
        dc.drawLine(centerX, centerY, drawableCirclePoint[:x], drawableCirclePoint[:y]);
    }

    // Draw a single month to the screen.
    function drawMonth(dc as Dc, month as Lang.Dictionary) {
        // If the width and height are different, use the lowest to calculate the maximum line size.
        var maxLineSize = (dc.getWidth() < dc.getHeight()) ? dc.getWidth() : dc.getHeight();
        maxLineSize = maxLineSize / 2;

        // Calculate the center point.
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;

        // Create a 10px line at the edge of the circle.
        var drawableCirclePoint =  calculateDrawableCirclePoint(centerX, centerY, maxLineSize - 10, month[:unitCirclePoint]);
        var drawableCirclePoint2 = calculateDrawableCirclePoint(centerX, centerY, maxLineSize, month[:unitCirclePoint]);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLUE);
        dc.drawLine(drawableCirclePoint[:x], drawableCirclePoint[:y], drawableCirclePoint2[:x], drawableCirclePoint2[:y]);
    }

    function calculateDrawableCirclePoint(centerX as Lang.Number, centerY as Lang.Number, maxLineSize as Lang.Number, unitCirclePoint as Lang.Dictionary) as Lang.Dictionary {
        var newX = centerX + maxLineSize * unitCirclePoint[:cos];
        var newY = centerY + -1 * maxLineSize * unitCirclePoint[:sin];
        return {
            :x => newX,
            :y => newY
        };
    }
}
