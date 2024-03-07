import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mercury/bar%20graph/individual_bar.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;
  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  //* List holds data for each bar
  List<IndividualBar> barData = [];

  //* Initialize the bar data - use monthly summary to create the bar data
  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
        (index) => IndividualBar(
          x: index, 
          y: widget.monthlySummary[index],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    //* Initialize the bar data
    initializeBarData();

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 100,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getBottomTitles,
            ),
          ),
        
        ),
        barGroups: barData.map(
          (data) => BarChartGroupData(
            x: data.x,
            barRods: [
              BarChartRodData(
                toY: data.y,
                width: 30
              ),
            ],
          )
        ).toList()
      )
    );
  }

  //* B O T T O M - T I T L E S
  Widget getBottomTitles(double value, TitleMeta meta) {
    const TextStyle style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Jan';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Apr';
        break;
      case 4:
        text = 'May';
        break;
      case 5:
        text = 'Jun';
        break;
      case 6:
        text = 'Jul';
        break;
      case 7:
        text = 'Aug';
        break;
      case 8:
        text = 'Sep';
        break;
      case 9:
        text = 'Oct';
        break;
      case 10:
        text = 'Nov';
        break;
      case 11:
        text = 'Dec';
        break;
      default:
        text = '';
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: style,
      )
    );
  }
}
