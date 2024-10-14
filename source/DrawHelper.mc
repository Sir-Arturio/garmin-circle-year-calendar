import Toybox.Graphics;
import Toybox.Lang;

class DrawHelper {
    var dc;

    // Center point of X-axis.
    var centerX;

    // Center point of Y-axis.
    var centerY;

    // Circle radius
    var circleRadius;

    public function initialize(dc as Dc) {
        self.dc = dc;

        // Calculate the center point.
        self.centerX = dc.getWidth() / 2;
        self.centerY = dc.getHeight() / 2;

        // Calculate circle radius
        self.circleRadius = self.centerX <= self.centerY ? self.centerX : self.centerY;
    }

    // Draw the current day.
    public function drawCurrentDay(dayPoint as Lang.Dictionary) {
        var drawableCirclePoint = self.calculateDrawableCirclePoint(self.circleRadius, dayPoint);
        self.dc.drawLine(self.centerX, self.centerY, drawableCirclePoint[:x], drawableCirclePoint[:y]);
    }

    // Draw the months.
    public function drawMonths(months as Lang.Array) {
        for (var i = 0; i < 12; i++) {
            self.drawMonth(months[i]);
        }
    }

    // Draw a single month to the screen.
    protected function drawMonth(month as Lang.Dictionary) {
        // Create a 10px line at the edge of the circle. For the first line (start of the year) draw a line of 40px
        var lineSize = month[:month] == 1 ? 40 : 10;
        var drawableCirclePoint = self.calculateDrawableCirclePoint(self.circleRadius - lineSize, month[:unitCirclePoint]);
        var drawableCirclePoint2 = self.calculateDrawableCirclePoint(self.circleRadius, month[:unitCirclePoint]);

        self.dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLUE);
        self.dc.drawLine(drawableCirclePoint[:x], drawableCirclePoint[:y], drawableCirclePoint2[:x], drawableCirclePoint2[:y]);
    }

    protected function calculateDrawableCirclePoint(lineLength as Lang.Number, unitCirclePoint as Lang.Dictionary) as Lang.Dictionary {
        var newX = self.centerX + lineLength * unitCirclePoint[:cos];
        var newY = self.centerY + -1 * lineLength * unitCirclePoint[:sin];
        return {
            :x => newX,
            :y => newY
        };
    }
}
