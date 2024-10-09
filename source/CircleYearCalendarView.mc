import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Math;

class CircleYearCalendarView extends WatchUi.View {

    // Initial offset where the year starts.
    var initialOffset;

    // Boolean if direction is clockwise.
    var isDirectionClockwise;

    function initialize() {
        // Start from the bottom of the circle.
        self.initialOffset = -0.5 * Math.PI;

        // Direction for the circle is counter-clockwise.
        self.isDirectionClockwise = false;

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

        var currentDayMoment = Gregorian.moment({:year => 2023, :month => 12, :day => 24});
        var currentDayInfo = Gregorian.info(currentDayMoment, Time.FORMAT_MEDIUM);
        var daysInCurrentYear = calculateDaysInYear(currentDayInfo);
        System.println(daysInCurrentYear);
        var calculatedMonths = self.calculateMonths(currentDayInfo);
        var calculatedCurrentDay = self.calculateCurrentDay(currentDayMoment);

        drawMonths(dc, calculatedMonths);
        drawCurrentDay(dc, calculatedCurrentDay);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // Calculate the number of days in the year of the moment.
    function calculateDaysInYear(currentMoment) as Lang.Number {
        var currentYear = Lang.format("$1$", [currentMoment.year]);
        var yearOptions = {
            :year => currentYear.toNumber(),
            :month => 1,
            :day => 1,
            :hour => 0,
            :minute => 0,
            :second => 0,
        };

        var beginningOfCurrentYear = Gregorian.moment(yearOptions);

        yearOptions[:year] = currentYear.toNumber() + 1;
        var beginningOfNextYear = Gregorian.moment(yearOptions);

        return beginningOfNextYear.subtract(beginningOfCurrentYear).divide(Gregorian.SECONDS_PER_DAY).value();
    }

    // Calculate months in the circle.
    function calculateMonths(currentMoment) as Lang.Array {
        // Calculated months.
        var months = [];

        var currentYear = Lang.format("$1$", [currentMoment.year]);
        currentYear = currentYear.toNumber();
        var daysInCurrentYear = calculateDaysInYear(currentMoment);

        // Initialize the year comparison moment here.
        var beginningOfYearMoment = null;

        // Loop through all months.
        for (var i = 1; i <= 12; i++) {
            var options = {
                :year => currentYear,
                :month => i,
                :day => 1,
            };

            // Create both moment and info of the beginning of the current month.
            var beginningOfMonthMoment = Gregorian.moment(options);
            var beginningOfMonthInfo = Gregorian.info(beginningOfMonthMoment, Time.FORMAT_SHORT);

            // Set the first month's moment as the beginningOfTheYear moment for comparison.
            if (beginningOfYearMoment == null) {
                beginningOfYearMoment = beginningOfMonthMoment;
            }

            var dayOfYear = beginningOfMonthMoment.subtract(beginningOfYearMoment).divide(Gregorian.SECONDS_PER_DAY).value();
            var point = calculateUnitCirclePoint(dayOfYear, daysInCurrentYear);

            months.add({
                :month => i,
                :dayOfYear => dayOfYear,
                :unitCirclePoint => point
            });
        }

        return months;
    }

    // Calculate the current day.
    function calculateCurrentDay(currentDayMoment) {
        var currentDayInfo = Gregorian.info(currentDayMoment, Time.FORMAT_SHORT);
        var daysInYear = calculateDaysInYear(currentDayInfo);
        var currentYear = Lang.format("$1$", [currentDayInfo.year]);
        currentYear = currentYear.toNumber();
        var beginningOfYearMoment = Gregorian.moment({:year => currentYear, :month => 1, :day => 1});

        var dayOfYear = calculateDistanceInDays(currentDayMoment, beginningOfYearMoment);
        dayOfYear = dayOfYear + 0.5;
        return calculateUnitCirclePoint(dayOfYear, daysInYear);
    }

    // Calculate distance in days.
    function calculateDistanceInDays(biggerMoment, smallerMoment) as Lang.Number {
        return biggerMoment.subtract(smallerMoment).divide(Gregorian.SECONDS_PER_DAY).value();
    }

    // Calculate the unit circle point for a day.
    function calculateUnitCirclePoint(day, allDays) as Lang.Dictionary {
        var point = {};

        // Unit circle is natively counter-clockwise.
        var direction = self.isDirectionClockwise ? -1 : 1;

        point[:radAngle] = self.initialOffset + (direction * (day.toFloat()/allDays) * 2 * Math.PI);
        point[:cos] = Math.cos(point[:radAngle]);
        point[:sin] = Math.sin(point[:radAngle]);
        return point;
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
