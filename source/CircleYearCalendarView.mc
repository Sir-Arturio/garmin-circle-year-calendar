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

        var currentDay = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var daysInCurrentYear = calculateDaysInYear(currentDay);
        System.println(daysInCurrentYear);
        var calculatedMonths = self.calculateMonths(currentDay);
        System.println(calculatedMonths[1][:month]);
        System.println(calculatedMonths[1][:dayOfYear]);
        System.println(calculatedMonths[1][:unitCirclePoint][:sin]);

        drawMonths(dc, calculatedMonths);
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

            var dateString = Lang.format(
                "DATE: $1$-$2$-$3$ | DayOfYear: $4$ $5$ | ANGLE $6$, COS: $7$, SIN: $8$",
                [
                    beginningOfMonthInfo.year,
                    beginningOfMonthInfo.month,
                    beginningOfMonthInfo.day,
                    dayOfYear,
                    daysInCurrentYear,
                    point[:radAngle],
                    point[:cos],
                    point[:sin]
                ]
            );
            System.println(dateString);
        }

        return months;
    }

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
    function drawMonths(dc as Dc, months as Array) {
        var month = months[0];

        // If the width and height are different, use the lowest to calculate the maximum line size.
        var maxLineSize = (dc.getWidth() < dc.getHeight()) ? dc.getWidth() : dc.getHeight();
        maxLineSize = maxLineSize / 2;

        // Calculate the center point.
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;

        System.println(Lang.format(
            "W: $1$, H: $2$, MAX L: $3$",
            [
                dc.getWidth(),
                dc.getHeight(),
                maxLineSize
            ]
        ));
        var drawableCirclePoint = calculateDrawableCirclePoint(centerX, centerY, maxLineSize, month[:unitCirclePoint]);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLUE);
        dc.drawLine(centerX, centerY, drawableCirclePoint[:x], drawableCirclePoint[:y]);
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
