//
//  PieChartViewController.swift
//  ExpenseTracker
//
//  Created by Bei Zhao on 11/26/17.
//  Copyright © 2017 Bei Zhao. All rights reserved.
//

import UIKit
import CorePlot
import CoreData

class PieChartViewController: ReminderStandardViewController,NSFetchedResultsControllerDelegate {

    @IBOutlet weak var hostView: CPTGraphHostingView!
    
    var items: [EItem] = []
    var sum = 0.0
    var NumofRecord = 0
    var Stringarray: [String] = []
    var Doublearray: [Double] = []
    
    /// Analysis the data gotten from the core data
    func analysis(){
        //Fetch the core data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            items = try context.fetch(EItem.fetchRequest())

            print(items)
        }
        catch{
            print("Fetching Failed")
        }
        
        var i = 0
        while i < items.count{
           sum = items[i].cost + sum
            
            // Get the number of records and the separate sum of different categories
            if Stringarray.contains(items[i].category!) {
                var j = 0
                while j < Stringarray.count{
                    if (Stringarray[j] == items[i].category) {
                        Doublearray[j] = Doublearray[j] + items[i].cost
                    }
                    j = j + 1
                }
            }
            else {
                NumofRecord = NumofRecord + 1
                Stringarray.append(items[i].category!)
                Doublearray.append(items[i].cost)
            }
            
            i = i + 1
        }
//        print(sum)
//        print(NumofRecord)
//        print(Stringarray)
//        print(Doublearray)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        analysis()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initPlot()
    }
    
    func initPlot() {
        configureHostView()
        configureGraph()
        configureChart()
        configureLegend()
    }
    
    func configureHostView() {
        hostView.allowPinchScaling = false
    }
    
    func configureGraph() {
        
        // 1 - Create and configure the graph
        let graph = CPTXYGraph(frame: hostView.bounds)
        hostView.hostedGraph = graph
        graph.paddingLeft = 0.0
        graph.paddingTop = 0.0
        graph.paddingRight = 0.0
        graph.paddingBottom = 0.0
        graph.axisSet = nil
        
        // 2 - Create text style
        let textStyle: CPTMutableTextStyle = CPTMutableTextStyle()
        textStyle.color = CPTColor.black()
        textStyle.fontName = "HelveticaNeue-Bold"
        textStyle.fontSize = 20.0
        textStyle.textAlignment = .center
        
        // 3 - Set graph title and text style
        graph.title = String(format: "\n Expense Analysis Result \n Total Spending %.2f $", sum)
        graph.accessibilityActivate()
        graph.titleTextStyle = textStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchor.top
    }
    
    func configureChart() {
        // 1 - Get a reference to the graph
        let graph = hostView.hostedGraph!
        
        // 2 - Create the chart
        let pieChart = CPTPieChart()
        pieChart.delegate = self
        pieChart.dataSource = self
        pieChart.pieRadius = (min(hostView.bounds.size.width, hostView.bounds.size.height) * 0.7) / 2
        pieChart.identifier = NSString(string: graph.title!)
        pieChart.startAngle = CGFloat(M_PI_4)
        pieChart.sliceDirection = .clockwise
        pieChart.labelOffset = 0.08 * pieChart.pieRadius
        
        // 3 - Configure border style
        let borderStyle = CPTMutableLineStyle()
        borderStyle.lineColor = CPTColor.white()
        borderStyle.lineWidth = 2.0
        pieChart.borderLineStyle = borderStyle
        
        // 4 - Configure text style
        let textStyle = CPTMutableTextStyle()
        textStyle.color = CPTColor.black()
        textStyle.textAlignment = .center
        pieChart.labelTextStyle = textStyle
        
        // 5 - Add chart to graph
        graph.add(pieChart)
        
    }
    
    func configureLegend() {
        // 1 - Get graph instance
        guard let graph = hostView.hostedGraph else { return }
        
        // 2 - Create legend
        let theLegend = CPTLegend(graph: graph)
        
        // 3 - Configure legend
        theLegend.numberOfColumns = 1
        theLegend.fill = CPTFill(color: CPTColor.white())
        let textStyle = CPTMutableTextStyle()
        textStyle.fontSize = 14
        theLegend.textStyle = textStyle
        
        // 4 - Add legend to graph
        graph.legend = theLegend
        if view.bounds.width > view.bounds.height {
            graph.legendAnchor = .right
            graph.legendDisplacement = CGPoint(x: -20, y: 0.0)
            
        } else {
            graph.legendAnchor = .bottomRight
            graph.legendDisplacement = CGPoint(x: -8.0, y: 8.0)
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension PieChartViewController: CPTPieChartDataSource, CPTPieChartDelegate {
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(NumofRecord)
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
    
        return Doublearray[Int(idx)]
    }
    
    func dataLabel(for plot: CPTPlot, record idx: UInt) -> CPTLayer? {
     
        let layer = CPTTextLayer(text: Stringarray[Int(idx)])
        layer.textStyle = plot.labelTextStyle
        return layer
   
    }
    
    func sliceFill(for pieChart: CPTPieChart, record idx: UInt) -> CPTFill? {
        switch idx {
        case 0:   return CPTFill(color: CPTColor(componentRed:1.0, green:0.0, blue:0.0, alpha:1.0))
        case 1:   return CPTFill(color: CPTColor(componentRed:0.0, green:1.0, blue:0.0, alpha:1.0))
        case 2:   return CPTFill(color: CPTColor(componentRed:0.0, green:0.0, blue:1.0, alpha:1.0))
        case 3:   return CPTFill(color: CPTColor(componentRed:0.0, green:1.0, blue:1.0, alpha:1.0))
        case 4:   return CPTFill(color: CPTColor(componentRed:1.0, green:1.0, blue:0.0, alpha:1.0))
        case 5:   return CPTFill(color: CPTColor(componentRed:1.0, green:0.0, blue:1.0, alpha:1.0))
        case 6:   return CPTFill(color: CPTColor(componentRed:1.0, green:0.5, blue:0.0, alpha:1.0))
        default:  return nil
        }
    }
    
    func legendTitle(for pieChart: CPTPieChart, record idx: UInt) -> String? {
        return String(format: "\(Stringarray[Int(idx)]) %.2f $", Doublearray[Int(idx)])
    }
}
    


