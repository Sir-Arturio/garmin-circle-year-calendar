import Toybox.Graphics;
import Toybox.Lang;

class DrawHelper {
    var dc as Dc;

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
        self.dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        self.dc.setPenWidth(1);
        self.dc.drawLine(self.centerX, self.centerY, drawableCirclePoint[:x], drawableCirclePoint[:y]);
    }

    // Draw the month arcs.
    public function drawMonthArcs(months as Lang.Array) {
        var color;
        var width = 10;
        var angle;
        var angle2;

        for (var i = 0; i < 12; i++) {
            angle = months[i][:unitCirclePoint][:angle];
            angle2 = (i < 11) ? months[i+1][:unitCirclePoint][:angle] : months[0][:unitCirclePoint][:angle];

            color = i % 2 ? Graphics.COLOR_YELLOW : Graphics.COLOR_BLUE;
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(width);
            dc.drawArc(self.centerX, self.centerY, circleRadius - (width / 2), Graphics.ARC_COUNTER_CLOCKWISE, angle, angle2);
        }
    }

    // Draw the month dividers.
    public function drawMonthDividers(months as Lang.Array) {
        for (var i = 0; i < 12; i++) {
            self.drawMonthDivider(months[i]);
        }
    }

    // Draw a single month divider to the screen.
    protected function drawMonthDivider(month as Lang.Dictionary) {
        // Create black month divider at the edge of the circle.
        // Use a bigger width at the beginning of the year to accomodate the year marker.
        var penWidth = month[:month] == 1 ? 5 : 3;
        var drawableCirclePoint = self.calculateDrawableCirclePoint(self.circleRadius - 10, month[:unitCirclePoint]);
        var drawableCirclePoint2 = self.calculateDrawableCirclePoint(self.circleRadius, month[:unitCirclePoint]);

        // Draw divider.
        self.dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        self.dc.setPenWidth(penWidth);
        self.dc.drawLine(drawableCirclePoint[:x], drawableCirclePoint[:y], drawableCirclePoint2[:x], drawableCirclePoint2[:y]);

        // At the beginning of the year, draw a year marker.
        if(month[:month] == 1) {
            self.dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            self.dc.setPenWidth(2);
            drawableCirclePoint = self.calculateDrawableCirclePoint(self.circleRadius - 40, month[:unitCirclePoint]);
            self.dc.drawLine(drawableCirclePoint[:x], drawableCirclePoint[:y], drawableCirclePoint2[:x], drawableCirclePoint2[:y]);
        }
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
