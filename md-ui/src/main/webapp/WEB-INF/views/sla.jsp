<%@taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<!DOCTYPE html>
<meta charset="utf-8">
<style>

body {
  font: 10px sans-serif;
}

.axis path,
.axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}

.bar {
  fill: steelblue;
}

.x.axis path {
  display: none;
}

</style>

<script>
	  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
	  //Please replace with your own analytics id
	  ga('create', 'UA-72345517-1', 'auto');
	  ga('send', 'pageview');
	</script>

                <!-- Include one of jTable styles. -->

                <link href="../css/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
                <link href="../css/jtables-bdre.css" rel="stylesheet" type="text/css" />
                <link href="../css/jquery-ui-1.10.3.custom.css" rel="stylesheet" type="text/css" />

                <!-- Include jTable script file. -->
                <script src="../js/jquery.min.js" type="text/javascript"></script>
                <script src="../js/jquery-ui-1.10.3.custom.js" type="text/javascript"></script>
                <script src="../js/jquery.jtable.js" type="text/javascript"></script>


<body>
<script>
var jsSLAMonitoringObjectList=[];
var processrunning = [];
var stateOfProcess = [];
</script>
<%
String processId=request.getParameter("processId");
%>
<div style="text-align: center;">
<h2><spring:message code="sla.page.sub_process_execution_time_graph"/> <%=processId %><h2>
</div>
<div>
<script src="../js/d3.min.js"></script>
<script>
var margin = {top: 20, right: 40, bottom: 30, left: 200},
    width = 1150 - margin.left - margin.right,
    height = 600 - margin.top - margin.bottom;

var x0 = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1);

var x1 = d3.scale.ordinal();

var y = d3.scale.linear()
    .range([height, 0]);

var color = d3.scale.ordinal()
    .range(["#98abc5", "#008000", "#d0743c"]);

var xAxis = d3.svg.axis()
    .scale(x0)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left")
    .tickFormat(d3.format(".2s"));

var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

</script>
<script>
var counter = 0;
var legendCounter = 0;
 function draw(data) {
  var ageNames = d3.keys(data[0]).filter(function(key) { return key !== "processId"; });

  data.forEach(function(d) {
    d.ages = ageNames.map(function(name) { return {name: name, value: +d[name]}; });
  });

  x0.domain(data.map(function(d) { return d.processId; }));
  x1.domain(ageNames).rangeRoundBands([0, x0.rangeBand()]);
  y.domain([0, d3.max(data, function(d) { return d3.max(d.ages, function(d) { return d.value; }); })]);

  svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text('<spring:message code="sla.page.y_axis_name"/>');

  var processId = svg.selectAll(".processId")
      .data(data)
    .enter().append("g")
      .attr("class", "processId")
      .attr("transform", function(d) { return "translate(" + x0(d.processId) + ",0)"; });

  processId.selectAll("rect")
      .data(function(d) { return d.ages; })
    .enter().append("rect")
      .attr("width", x1.rangeBand())
      .attr("x", function(d) {return x1(d.name); })
      .attr("y", function(d) {return y(d.value); })
      .attr("height", function(d) { return height - y(d.value); })
      .style("fill", function(d) {
          if(d.name=="Current" && processrunning[counter]==true)
          {
            counter++;
            return "#FFFF00";
          }
          else if (d.name=="Current")
          {

            if(stateOfProcess[counter]==6) {

                counter++;
                return "#FF0000";
            }
            counter++;
            return "#d0743c";
          }
          else
          {
            if(d.name=="Average")
                return "#98abc5";
            else (d.name=="SLA")
                return "#008000";
          }
       });

  var legend = svg.selectAll(".legend")
      .data(ageNames.slice().reverse())
    .enter().append("g")
      .attr("class", "legend")
      .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

  legend.append("rect")
      .attr("x", width - 18)
      .attr("width", 18)
      .attr("height", 18)
      .style("fill", function(d){
        if (d=="SLA")
            return "#008000";
        else if (d=="Average")
            return "#98abc5";
        else if (d=="Current")
            return "#d0743c";
        else if (d=="Running")
            return "#FFFF00";
        else if (d=="Failed")
            return "#FF0000";
      });

  legend.append("text")
      .attr("x", width - 24)
      .attr("y", 9)
      .attr("dy", ".35em")
      .style("text-anchor", "end")
      .text(function(d) { return d; });

};
</script>
<script>
  function jsSLAMonitoringObjectArrayList(data){
  for(var i=0;i<data.Record.length;i++)
  {
  var obj=data.Record[i];
  var slaBean=new jsSLAMonitoringObject(obj.processId,obj.currentExecutionTime,obj.averageExecutionTime,obj.sLATime,obj.running,obj.failed);
            jsSLAMonitoringObjectList.push(slaBean);
            processrunning.push(obj.processRunning);
            stateOfProcess.push(obj.stateOfProcess)
  }
  draw(jsSLAMonitoringObjectList);
  }
</script>
<script>
SLAMonitoring("<%=processId %>");

function jsSLAMonitoringObject(processId, currentExecutionTime, averageExecutionTime, sLATime, running, failed) {
                     this.processId = processId;
                     this.Current = currentExecutionTime;
                     this.Average = averageExecutionTime;
                     this.SLA = sLATime;
                     this.Running = running;
                     this.Failed = failed;
                 }

function SLAMonitoring(pid)
                     {
                     $.ajax({
                                   url: '/mdrest/process/SLAMonitoring/' + pid,
                                    type: 'GET',
                                    dataType: 'json',
                                     success: function(data) {
                                     if (data.Result == "OK") {
                                     console.log(data);
                                   jsSLAMonitoringObjectArrayList(data);
                                  }
                               if (data.Result == "ERROR")
                                 alert(data.Message);
                            },
                             error: function() {
                             alert('<spring:message code="sla.page.error_message"/>');
                         }
                          });
                     }
</script>
</div>
<hr  style="width:80%">
<center><b><spring:message code="sla.page.x_axis_name"/> </b></center>
