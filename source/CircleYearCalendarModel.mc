import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;

class CircleYearCalendarModel {
    // Initial offset where the year starts.
    var initialOffset;

    // Boolean if direction is clockwise.
    var isDirectionClockwise;

    // The current moment.
    var currentMoment;

    // The Gregorian Info of the current moment.
    var currentMomentInfo;

    // The beginning of the current year moment.
    var beginningOfCurrentYearMoment;

    // Days in the moment's year.
    var daysInYear;

    public function initialize(newMoment, offsetRad, offsetDays, isDirectionClockwise as Lang.Boolean) {
        self.currentMoment = newMoment;
        self.currentMomentInfo = Gregorian.info(newMoment, Time.FORMAT_SHORT);

        self.beginningOfCurrentYearMoment = Gregorian.moment({:year => self.currentMomentInfo.year, :month => 1, :day => 1});

        self.daysInYear = self.calculateDaysInYear();

        self.initialOffset = offsetRad + (offsetDays/self.daysInYear.toFloat()) * Math.PI * 2;

        // Direction for the circle is counter-clockwise.
        self.isDirectionClockwise = isDirectionClockwise;
    }

    // Calculate months in the circle.
    public function calculateMonths() as Lang.Array {
        // Calculated months.
        var months = [];

        // Loop through all months.
        for (var i = 1; i <= 12; i++) {
            var options = {
                :year => self.currentMomentInfo.year,
                :month => i,
                :day => 1,
            };

            // Create both moment and info of the beginning of the current month.
            var beginningOfMonthMoment = Gregorian.moment(options);

            var dayOfYear = self.calculateDistanceInDays(beginningOfMonthMoment, self.beginningOfCurrentYearMoment);
            var point = calculateUnitCirclePointFromDay(dayOfYear);

            months.add({
                :month => i,
                :dayOfYear => dayOfYear,
                :unitCirclePoint => point
            });
        }

        return months;
    }

    // Calculate the current day.
    public function calculateCurrentDay() as Lang.Array {
        var dayOfYear = calculateDistanceInDays(self.currentMoment, self.beginningOfCurrentYearMoment);
        dayOfYear = dayOfYear + 0.5;
        var currentDayPoint = calculateUnitCirclePointFromDay(dayOfYear);

        var currentDayHandPoints = [];
        currentDayHandPoints.add(currentDayPoint);
        currentDayHandPoints.add(calculateUnitCirclePoint(currentDayPoint[:radAngle] + Math.PI/2));
        currentDayHandPoints.add(calculateUnitCirclePoint(currentDayPoint[:radAngle] - Math.PI/2));

        return currentDayHandPoints;
    }

    // Calculate the number of days in the year.
    protected function calculateDaysInYear() as Lang.Number {
        var nextYear = self.currentMomentInfo.year + 1;
        var beginningOfNextYear = Gregorian.moment({:year => nextYear, :month => 1, :day => 1});

        return self.calculateDistanceInDays(beginningOfNextYear, self.beginningOfCurrentYearMoment);
    }

    // Calculate distance in days.
    protected function calculateDistanceInDays(biggerMoment, smallerMoment) as Lang.Number {
        return biggerMoment.subtract(smallerMoment).divide(Gregorian.SECONDS_PER_DAY).value();
    }

    // Calculate the unit circle point for a day.
    protected function calculateUnitCirclePointFromDay(day) as Lang.Dictionary {
        // Unit circle is natively counter-clockwise.
        var direction = self.isDirectionClockwise ? -1 : 1;

        return calculateUnitCirclePoint(self.initialOffset + (direction * (day.toFloat()/self.daysInYear) * 2 * Math.PI));
    }

    // Calculate the unit circle point for a rad angle.
    protected function calculateUnitCirclePoint(radAngle) as Lang.Dictionary {
        var point = {};

        point[:radAngle] = radAngle;
        point[:angle] = (point[:radAngle] / (2.0 * Math.PI)) * 360;
        point[:cos] = Math.cos(point[:radAngle]);
        point[:sin] = Math.sin(point[:radAngle]);
        return point;
    }
}
