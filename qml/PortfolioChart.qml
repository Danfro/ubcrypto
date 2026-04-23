import QtQuick 2.7
import QtCharts 2.0
import QtQuick.Controls 2.2
import "theme.js" as AppTheme

Item {
    id: root
    width: parent.width
    height: parent.height

    property alias chartTitleText: chartTitle.text

    // Title
    Text {
        id: chartTitle
        text: i18n.tr("Portfolio Value Over Time")
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: units.gu(2) // Assuming units is defined elsewhere, or use a fixed pixel size like 20
        color: "#444"
        padding: 10
    }

    // Line Chart (now using SplineSeries)
    ChartView {
        id: portfolioChart
        anchors.fill: parent
        antialiasing: true

        ValueAxis {
            id: yAxis
            min: 0
            titletext: i18n.tr("Value ($)")
        }

        // ***** CHANGE THIS LINE *****
        SplineSeries { // <--- Changed from LineSeries to SplineSeries
            id: series
            axisY: yAxis
            axisX: xAxis
            // You can also add properties specific to SplineSeries if needed,
            // like pen properties for line thickness/color.
            // For example:
            // pen.color: "blue"
            // pen.width: 2
        }

        DateTimeAxis {
            id: xAxis
            titletext: i18n.tr("Date")
            format: "MM-dd" // Or "yyyy-MM-dd", adjust as per clutter tips
            tickCount: 5
            labelsAngle: -45 // Keeps labels from overlapping
        }
    }

    // In your PortfolioChart.qml
    function load(data) {
        series.clear();

        console.log("--- DEBUG: Loading Chart Data ---");
        // VERY IMPORTANT: Check this output. It should be a JSON array like: [{"date":"2025-06-20","total_value":...}, ...]
        console.log("DEBUG: Raw data received (as string):", JSON.stringify(data));

        if (!data || data.length === 0) {
            xAxis.min = new Date();
            xAxis.max = new Date();
            yAxis.max = 0;
            console.log("DEBUG: No data or empty data received. Axis reset.");
            return;
        }

        var minDate = null; // Initialize to null for better handling if first date is invalid
        var maxDate = null;

        for (var i = 0; i < data.length; ++i) {
            // Ensure data[i] is an object and has a 'date' property
            if (!data[i] || typeof data[i].date === 'undefined' || typeof data[i].total_value === 'undefined') {
                console.error("DEBUG: ERROR: data[" + i + "] is malformed (not object or missing date/total_value). Skipping.");
                continue; // Skip this malformed point
            }

            var dateString = data[i].date; // This is the string that new Date() will try to parse
            var yValue = data[i].total_value;

            console.log("DEBUG: Processing item", i, ":");
            console.log("DEBUG:   Original dateString from data[i].date:", dateString);

            var date = new Date(dateString); // Attempt to parse the date string

            console.log("DEBUG:   Result of new Date(dateString):", date);
            // This is the most critical check: Is this 'NaN'? If so, the dateString is invalid.
            console.log("DEBUG:   Result of date.getTime():", date.getTime());

            // If the date is invalid, do NOT append it to the series
            if (isNaN(date.getTime())) {
                console.error("DEBUG: ERROR: Invalid date parsed for string:", dateString + ". This point will be skipped.");
                continue;
            }

            series.append(date.getTime(), yValue);

            // Update min/max dates for the axis range
            if (minDate === null || date < minDate) minDate = date;
            if (maxDate === null || date > maxDate) maxDate = date;
        }

        // Only set axis min/max if we actually added valid points
        if (series.count > 0) {
            xAxis.min = minDate;
            xAxis.max = maxDate;
        } else {
            // If no valid points were added, reset axes to default or avoid showing "Invalid Date"
            xAxis.min = new Date(); // Or some default start date
            xAxis.max = new Date(); // Or some default end date
        }

        var maxY = 0; // Default to 0 if no data
        if (series.count > 0) { // Calculate maxY only for valid points
            // Re-map the original data, or iterate through appended series points
            // It's safer to re-map the original data's total_value if you're skipping invalid points
            var validYValues = data.filter(item => !isNaN(new Date(item.date).getTime())).map(item => item.total_value);
            if (validYValues.length > 0) {
                 maxY = Math.max.apply(Math, validYValues);
            }
        }
        yAxis.max = maxY * 1.1; // Add some padding above the max value
        console.log("DEBUG: --- Chart Loading Complete ---");
    }
}
