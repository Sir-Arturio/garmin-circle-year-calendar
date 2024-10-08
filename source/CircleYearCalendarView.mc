import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;

class CircleYearCalendarView extends WatchUi.View {

    // Initial offset where the year starts.
    var initialOffset;

    // Direction where the year continues (1 for clockwise, -1 for anti-clockwise).
    var direction;

    function initialize() {
        // Start from the bottom of the circle.
        self.initialOffset = -0.5 * Math.PI;

        // Direction for the circle is anti-clockwise.
        self.direction = -1;

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
        var currentDay = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var daysInCurrentYear = calculateDaysInYear(currentDay);
        System.println(daysInCurrentYear);
        self.calculateMonths(currentDay);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
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
    function calculateMonths(currentMoment) {
        var currentYear = Lang.format("$1$", [currentMoment.year]);
        currentYear = currentYear.toNumber();

        for (var i = 1; i <= 12; i++) {
            var options = {
                :year => currentYear,
                :month => i,
                :day => 1,
            };
            var beginningOfMonthMoment = Gregorian.info(Gregorian.moment(options), Time.FORMAT_SHORT);
            var dateString = Lang.format(
                "$1$-$2$-$3$",
                [
                    beginningOfMonthMoment.year,
                    beginningOfMonthMoment.month,
                    beginningOfMonthMoment.day
                ]
            );
            System.println(dateString);
        }
    }
}
