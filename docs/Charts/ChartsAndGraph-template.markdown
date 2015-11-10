# 
<sub>These materials are for informational purposes only and do not constitute legal advice. You should contact an attorney to obtain advice with respect to the development of a research app and any applicable laws.</sub>

# Charts
ResearchKit provides charts APIs to visualize your data into charts. 

The screenshots below shows different types of ResearchKit's charts:

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ChartsImages/Overview/PieChartOverview.png" style="width: 100%;border: solid black 1px; ">Pie Chart</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ChartsImages/Overview/LineGraphChartOverview.png" style="width: 100%;border: solid black 1px;">Line graph chart</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ChartsImages/Overview/LineGraphChartMultipleLinesOverview.png" style="width: 100%;border: solid black 1px;">Line graph chart with multiple lines.</p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ChartsImages/Overview/DiscreteGraphChartOverview.png" style="width: 100%;border: solid black 1px; ">Discrete graph chart.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ChartsImages/Overview/DiscereteGraphChartMultipleLinesOverview.png" style="width: 100%;border: solid black 1px;">Discrete graph chart with multiple points.</p>
<p style="clear: both;">

To visualize the data into charts, create a data source which supply data into charts. After creating the data source, create a UIView chart object (chart-view object), connect it with the data source, select the options to customize your chart (optional), and present it in a view controller.

##Implementing Data Source Protocol
A chart-view object which presents the charts in a view controller, must be connected to a data source. The data source provides information that chart-view object require to construct a chart. The data source must adopt the `ORKGraphChartViewDataSource` (for a graph chart)  or  `ORKPieChartViewDataSource`(for a pie chart) protocol.

The required methods of the protocol provides the number of points or segments and  their values to the chart-view object. The optional methods of the protocol helps in further configuring data, such as color of the x-axis or segments.

###Pie Chart Data Source Protocol
The pie chart data source class must adopt the `ORKPieChartViewDataSource` protocol. To construct a pie chart, it is required to know the number of segments and the value of each segment. The following required methods of the pie chart data source protocol, provides these number and values to the pie chart-view object:

####Number Of Segments In Pie Chart 
To specify the number of segments in a pie chart, implement the `numberOfSegmentsInPieChartView` method which returns an integer indicating the number of segment in the pie chart.

The example below creates three segments in a pie chart:

	func numberOfSegmentsInPieChartView(pieChartView: ORKPieChartView ) -> Int {
        return 3 
    }

####Value For Segment
To draw the segments, you must specify the value of the each segment. To provide value for every segment of the pie chart, implement the `valueForSegmentAtIndex` method.
<strong>NG: should I mention that as of now only percentage value of the segment can be display?Or am I missing something here? Can we show the value in the segment without the values been converted into percent?</strong>

The example below gives a value 3 to each segment of a pie chart: 

	func pieChartView(pieChartView: ORKPieChartView, valueForSegmentAtIndex index: Int) -> CGFloat {
        return 3
    }
    
There are optional methods in the pie chart data source protocol which helps in customizing the look and feel of the data, such as color of the segment, title for each segment, and so on. To learn about all the customizable properties in the pie chart data source protocol, see `ORKPieChartViewDataSource`. 

Here's how a pie chart data source class may look like:
	
	class PieChartDataSource: NSObject, ORKPieChartViewDataSource {
      
	//Creating colors for segments 
	 let colors = [
        
        UIColor(red: 217/225, green: 217/255, blue: 217/225, alpha: 1),
        UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1),
        UIColor(red: 244/255, green: 200/255, blue: 74/255, alpha: 1)
    ]
    let values = [60.0, 20.0, 15.0]
    
    //Required methods
    func numberOfSegmentsInPieChartView(pieChartView: ORKPieChartView ) -> Int {
        return colors.count
    }
    
    func pieChartView(pieChartView: ORKPieChartView, valueForSegmentAtIndex index: Int) -> CGFloat {
        return CGFloat(values[index])
    }
    	//Optional methods
	// Giving color to each segment in the pie chart
    func pieChartView(pieChartView: ORKPieChartView, colorForSegmentAtIndex index: Int) -> UIColor {
        return colors[index]
    }
    
	//Giving title for every segment in the pie chart
    func pieChartView(pieChartView: ORKPieChartView, titleForSegmentAtIndex index: Int) -> String {
        //switch statement
        switch index {
        case 0:
            return "Steps taken   "
        case 1:
            return "Tasks completed"
        case 2:
            return "Surveys completed"
        default:
            return "task \(index + 1)"
        }
    } }	
    
What next? After creating a pie chart data source class, create a pie chart-view object, which presents the data source class's data into a pie chart. 

###Graph Chart Data Source Protocol
Line and discrete graph chart uses the same `ORKGraphChartViewDataSource` data source protocol. To construct a graph, it is required to know the number of points (on x-axis) and the value at every point (on Y-axis) in the graph. The following required methods of the graph chart data source protocol, provides these number and values to the graph chart-view object:

####Number of Points
The `numberOfPointsForPlotIndex` method returns an integer, which represents the number of points in a graph on X-axis. When drawing a single-plot graph, return zero for this method. 
 
The following code snippet tell the graph chart-view object to draw five points on the X -axis of the graph: 

	func graphChartView(graphChartView: ORKGraphChartView, numberOfPointsForPlotIndex plotIndex: Int) -> Int {
        return 5
    }
   
####Point Values 
The `graphChartView:pointForPointIndex:plotIndex: ` method provide the range point to be plotted at the specified point index (X- axis) for the specified plot (Y-Axis). This method is called for ever point you specify in the `numberOfPointsForPlotIndex` method. 
The value returned by this method is of  `ORKRangedPoint` type, which represents a ranged point used in a graph plot.

<strong>NG: Please check my Y & X axis references</strong>

####Drawing Multiple Lines in a Graph Chart     
By default the graph chart-view object assumes that it has a single plot to draw. To draw more than one plot on a graph, use the `numberOfPlotsInGraphChartView` method and specify the number of plots in a graph. This is an optional data source method, but useful when you are drawing more than one plot on a graph chart.

Here's how a graph chart-view object to draw two plots:
	
	 //Optional methods
    func numberOfPlotsInGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return 2
    }

Here's how a line graph chart's data source class may look like:
    
    class LineGraphDataSource: NSObject, ORKGraphChartViewDataSource {
    
    var plotPoints =
    [
        [
            ORKRangedPoint(value: 200),
            ORKRangedPoint(value: 450),
            ORKRangedPoint(value: 500),
            ORKRangedPoint(value: 250),
            ORKRangedPoint(value: 300),
            ORKRangedPoint(value: 600),
            ORKRangedPoint(value: 300),
        ],

    ]
    
    //Required methods
    
    func graphChartView(graphChartView: ORKGraphChartView, pointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKRangedPoint {
        
        return plotPoints[plotIndex][pointIndex]
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, numberOfPointsForPlotIndex plotIndex: Int) -> Int {
        return plotPoints[plotIndex].count
    }
    
    //Optional methods
    
	//Drawing multiple plots on the graph chart view
    func numberOfPlotsInGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return plotPoints.count
    }
    
    //Maximum value on Y axis
    func maximumValueForGraphChartView(graphChartView: ORKGraphChartView) -> CGFloat {
        return 1000
    }
     //Minimum value on Y axis
    func minimumValueForGraphChartView(graphChartView: ORKGraphChartView) -> CGFloat {
        return 0
    }
     //Providing titles for X-axis
    func graphChartView(graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {

        switch pointIndex {
        case 0:
            return "Mon"
        case 1:
            return "Tues"
        case 2:
            return "Wed"
        case 3:
            return "Thurs"
        case 4:
            return "Fri"
        case 5:
            return "Sat"
        case 6:
            return "Sun "
        default:
            return "Day \(pointIndex + 1)"
        }
        
    }
    
	//Giving color to plot index
    func graphChartView(graphChartView: ORKGraphChartView, colorForPlotIndex plotIndex: Int) -> UIColor {
        if plotIndex == 0 {
            return UIColor.purpleColor()
            
        }
    } }
    
 A discrete graph chart uses the same data source protocol as line graph chart, hence the data source class may look similar to a line class data source as shown above.
 
What next? After creating a line/discrete graph chart data source class, create a line/discrete graph chart-view object, which presents the data source class's data into a graph chart.

#####Reloading data
setDataSource
<strong>NG: I couldn't find a use case for setDataSource method, could you help</strong>.

##Presenting Charts
After creating a data source class, which populates the chart with data, create a chart-view object which present the chart in a view controller.

### Pie Charts
A pie chart, is a circular chart divided into segments.

####Visualizing Pie Chart
To present data in a pie chart, construct a pie chart-view object (an instance of  the `ORKPieChartView` class). To do so, create a UIView in a UIViewController, change the custom class of the view to the `ORKPieChartView` class in the storyboard. Now, link this view to your code using an IBOutlet, this is your pie chart-view object. After you create a pie chart-view object, connect it with a data source. At this point pie chart-view is ready to present the data from the connected data source class. 

The following example demonstrates, creating a pie chart-view object connecting it to a datasource and customizing some of the pie chart-view properties:
	
	//Create pie chart-view object
     @IBOutlet weak var pieChartView: ORKPieChartView!
	 override func viewDidLoad() {
        super.viewDidLoad()
        //Connect the pie chart-view object to a data source
        pieChartView.dataSource = pieChartDataSource
        
	// Optional custom configuration
        pieChartView.showsTitleAboveChart = false
        pieChartView.showsPercentageLabels = true
        pieChartView.drawsClockwise = true
        pieChartView.titleColor = UIColor.purpleColor()
        pieChartView.textColor = UIColor.purpleColor()
        pieChartView.title = "Weekly"
        pieChartView.text = "Report"
        pieChartView.lineWidth = 10
        pieChartView.showsPercentageLabels = true
    
    }
    
Here's how the pie chart created by the code above, connected with a data source class discussed before may look like:
<center>
<figure>
<img src="ChartsImages/PieChart/Chart1.png" width="25%" alt="Instruction step"  style="border: solid black 1px;"  align="middle"/>
  <figcaption> <center>Pie chart.</center></figcaption>
</figure>
</center>

### Line Graph Chart
A line graph chart is a type of chart which displays information as a series of data points connected by a straight line. For example, to visualize the number of steps taken by a user everyday in a week use a Line graph chart. ResearchKit charts APIs allows multiple plots on a graph chart.

####Visualizing Line Graph Chart
To present data in a line graph chart, construct a line graph chart-view object (an instance of the `ORKLineGraphChartView` class). To do so, create a UIView in a UIViewController, change the custom class of the view to the `ORKLineGraphChartView` class in the storyboard. Now, link this view to your code using an IBOutlet, this is your line graph chart-view object. After you create a line graph chart-view object, connect it with a data source. At this point line graph chart-view is ready to present the data from the connected data source class.

The following example demonstrates, creating a line graph chart-view object connecting it to a data source and customizing some of the line graph chart-view properties:
	
	// Create a line graph view object 
	var lineGraphView: ORKLineGraphChartView! 
	  
	 override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect the line graph view object to a data source
        lineGraphView.dataSource = lineGraphChartDataSource()
        
        // Optional custom configuration
        lineGraphView.showsHorizontalReferenceLines = true
        lineGraphView.showsVerticalReferenceLines = true
        lineGraphView.axisColor = UIColor.whiteColor()
        lineGraphView.verticalAxisTitleColor = UIColor.orangeColor()
        lineGraphView.showsHorizontalReferenceLines = true
        lineGraphView.showsVerticalReferenceLines = true
        lineGraphView.scrubberLineColor = UIColor.redColor()
    }
    
Here's how the line graph chart created by the code above, connected with a data source class discussed before may look like:
<center>
<figure>
<img src="ChartsImages/CustomizedLineGraph.png" width="25%" alt="Instruction step"  style="border: solid black 1px;"  align="middle"/>
  <figcaption> <center>Line graph chart.</center></figcaption>
</figure>
</center>

###Discrete Graph Chart
A discrete graph chart is a type of chart which displays information as a series of data points, where each series are evenly spaced across the axis according to tier row index. A discrete graph chart is a better fit when you want to visualize different range. For example, if you want to visualize a heart rate range of a user over a past month. ResearchKit charts APIs allows you to present more than one line on a line graph chart. 

####Visualizing Discrete Graphs Charts
To present data in a discrete graph chart, construct a discrete graph chart-view object (an instance of the `ORKDiscreteGraphChartView` class). To do so, create a UIView in your UIViewController, change the custom class of the view to the `ORKDiscreteGraphChartView` class in the storyboard. Now, link this view to your code using an IBOutlet, this is your discrete graph chart-view object. After you create a discrete graph chart-view object, connect it with a data source. At this point discrete graph chart-view is ready to present the data from the connected data source class. 

The following example demonstrates, creating a discrete graph chart-view object connecting it to a data source and customizing some of the discrete graph chart-view properties:
	
	// Creating discrete graph chart-view object
	@IBOutlet weak var discreteGraphChart: ORKDiscreteGraphChartView!

    //Connecting discrete graph chart-view object to a data source
    let discreteGraphChartDataSource = DiscreteGraphDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        discreteGraphChart.dataSource = discreteGraphChartDataSource
        // Optional custom configuration
        discreteGraphChart.showsVerticalReferenceLines = true
        discreteGraphChart.drawsConnectedRanges = true
    }

    
Here's how the discrete graph chart created by the code above, connected with a data source class discussed before may look like:
<center>
<figure>
<img src="ChartsImages/DiscreteGraphChart.png" width="25%"  style="border: solid black 1px;"  align="middle"/>
  <figcaption> <center>Line graph chart.</center></figcaption>
</figure>
</center>

##Customization
You can use ResearchKit's charts APIs with their default setting - all customization is optional and the basic setup is ready-to-use. However, charts can be easily customizable in case the default setup does not work for your app. Every chart exposes number of options that customize its look and feel. To learn about all the customizable properties of a pie, line graph, and discrete graph chart objects, see `ORKPieChartView`, `ORKGraphChartView`, and `ORKDiscreteGraphChartView`.

## Adding titles in the Chart
To add titles along the X-Axis in a line or discrete graph chart, implement the `titleForXAxisAtPointIndex` method in the data source class. This method provides the title to display adjacent to each division on the x-axis. For the Y-axis, you can display maximum/minimum values using the `maximumValueForGraphChartView:` or `minimumValueForGraphChartView:` properties or to display an image instead of minimum/maximum values use the `MaximumValueImage` or  `minimumValueImage` properties.

The following code snippet adds titles on a x-axis of a discrete graph chart:

	 func graphChartView(graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        
        switch pointIndex {
        case 0:
            return "Jan"
        case 1:
            return "Feb"
        case 2:
            return "Mar"
        case 3:
            return "Apr"
            
        default:
            return "Month \(pointIndex + 1)"
        }
        
    }    
Here's how the discrete graph chart's x-axis title look like from the code above:
<center>
<figure>
<img src="ChartsImages/DiscreteGraphChart2.png" width="25%" style="border: solid black 1px;"  align="middle"/>
  <figcaption> <center>Discrete graph chart with custom titles.</center></figcaption>
</figure>
</center>

Similarly to name the segments in a pie chart, implement the `titleForSegmentAtIndex` method in a pie chart data source class. 

The following code snippet adds titles to the segments in a pie chart:

	  func pieChartView(pieChartView: ORKPieChartView, titleForSegmentAtIndex index: Int) -> String {
        
        switch index {
        case 0:
            return "Custom title 1"
        case 1:
            return "Custom title 2"
        case 2:
            return "Custom title 2"
        default:
            return "Custom title \(index + 1)"
        }
    }
    
Here's how the pie chart segments title look like from the code above:
<center>
<figure>
<img src="ChartsImages/PieChart/CustomTitlePieChart.png" width="25%" style="border: solid black 1px;"  align="middle"/>
  <figcaption> <center>Pie chart with custom titles.</center></figcaption>
</figure>
</center>

##Pan Gesture
By default graph chart view implements a pan gesture for you. In the graph chart view when the user touches and drags his/her finger along the graph chart, a label  appears on top of the closest dot from the user's finger. This label displays the value of the point. 
To extend the default functionality implement the `ORKGraphChartViewDelegate` protocol. The graph chart view delegate protocol forwards the pan gesture events occurring within the bounds of an `ORKGraphChartView` object.

