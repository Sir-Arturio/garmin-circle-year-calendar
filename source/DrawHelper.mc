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

    // Arc width
    var arcWidth;

    public function initialize(dc as Dc, arcWidth) {
        self.dc = dc;

        // Calculate the center point.
        self.centerX = dc.getWidth() / 2;
        self.centerY = dc.getHeight() / 2;

        // Calculate circle radius
        self.circleRadius = self.centerX <= self.centerY ? self.centerX : self.centerY;

        self.arcWidth = arcWidth;
    }

    // Draw the current day.
    public function drawCurrentDay(currentDayHandPoints as Lang.Array) {
        var currentDayHandPolygon = [];

        // The tip of the current day hand.
        // Leave 5px gap between the current day marker and the month arc.
        currentDayHandPolygon.add(self.calculateDrawableCirclePoint(self.circleRadius - self.arcWidth - 5, currentDayHandPoints[0]));

        // The base of the current day hand.
        currentDayHandPolygon.add(self.calculateDrawableCirclePoint(5, currentDayHandPoints[1]));
        currentDayHandPolygon.add(self.calculateDrawableCirclePoint(5, currentDayHandPoints[2]));

        self.dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        self.dc.setPenWidth(1);
        self.dc.fillPolygon(currentDayHandPolygon);
    }

    // Draw the month arcs.
    public function drawMonthArcs(months as Lang.Array, monthColors as Lang.Array) {
        var angle;
        var angle2;

        for (var i = 0; i < 12; i++) {
            // Ceil and floor the angles to prevent day arcs from bleeding together.
            angle = Math.ceil(months[i][:unitCirclePoint][:angle]);
            angle2 = (i < 11) ? months[i+1][:unitCirclePoint][:angle] : months[0][:unitCirclePoint][:angle];
            angle2 = Math.floor(angle2);

            dc.setColor(monthColors[i], Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(self.arcWidth);
            dc.drawArc(self.centerX, self.centerY, circleRadius - (self.arcWidth / 2), Graphics.ARC_COUNTER_CLOCKWISE, angle, angle2);
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
        var drawableCirclePoint = self.calculateDrawableCirclePoint(self.circleRadius - self.arcWidth, month[:unitCirclePoint]);
        var drawableCirclePoint2 = self.calculateDrawableCirclePoint(self.circleRadius, month[:unitCirclePoint]);

        // Draw divider.
        self.dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        self.dc.setPenWidth(penWidth);
        self.dc.drawLine(drawableCirclePoint[0], drawableCirclePoint[1], drawableCirclePoint2[0], drawableCirclePoint2[1]);

        // At the beginning of the year, draw a year marker.
        if(month[:month] == 1) {
            self.dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            self.dc.setPenWidth(2);
            drawableCirclePoint = self.calculateDrawableCirclePoint(self.circleRadius - 40, month[:unitCirclePoint]);
            self.dc.drawLine(drawableCirclePoint[0], drawableCirclePoint[1], drawableCirclePoint2[0], drawableCirclePoint2[1]);
        }
    }

    protected function calculateDrawableCirclePoint(lineLength as Lang.Number, unitCirclePoint as Lang.Dictionary) as Lang.Array {
        var newX = self.centerX + lineLength * unitCirclePoint[:cos];
        var newY = self.centerY + -1 * lineLength * unitCirclePoint[:sin];
        return [ newX, newY ];
    }
}
