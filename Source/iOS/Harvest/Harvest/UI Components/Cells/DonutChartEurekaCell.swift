//
//  DonutChartEurekaCell.swift
//  Harvest
//
//  Created by Letanyan Arumugam on 2018/07/06.
//  Copyright © 2018 University of Pretoria. All rights reserved.
//

import Eureka
import Charts

public class DonutChartCell: Cell<Session>, CellType {
  @IBOutlet weak var chart: PieChartView!
  
  public override func setup() {
    super.setup()
    chart.chartDescription = nil
    chart.legend.enabled = false
    chart.noDataText = "No Data Available to Show"
    chart.noDataFont = UIFont.systemFont(ofSize: 22, weight: .heavy)
    height = {
      min(self.superview?.frame.width ?? 360, self.superview?.frame.height ?? 360)
    }
  }
  
  public override func update() {
    super.update()
    chart.data = row?.value?.workerPerformanceSummary()
    
    if let summary = row?.value?.collectionBagSummary() {
      switch summary {
      case let .mass(m):
        let formatter = MassFormatter()
        let fm = formatter.string(fromKilograms: m)
        chart.centerText = "Total Collected: \(fm)"
      case let .count(c):
        chart.centerText = "Total Collected: \(c) Bags"
      }
    } else {
      chart.centerText = "--"
    }
    
//    let wname = row.value?.foreman.name ?? "Unknown Foreman"
//    let dist = row?.value?.track.euclideanDistance() ?? .nan
//    
//    chart.centerText = "\(wname) Traveled: \n\(dist == .nan ? "--" : Int(dist).description + "m")"
  }
}

// The custom Row also has the cell: CustomCell and its correspond value
public final class DonutChartRow: Row<DonutChartCell>, RowType {
  required public init(tag: String?) {
    super.init(tag: tag)
    // We set the cellProvider to load the .xib corresponding to our cell
    cellProvider = CellProvider<DonutChartCell>(nibName: "DonutChartEurekaCell")
  }
}

extension Session {
  func workerPerformanceSummary() -> PieChartData? {
    let result = PieChartDataSet()
    var colorSet = [UIColor]()
    var i = 0
    let sortedWorkers = collections.sorted {
      UIColor.huePrecedence(key: $0.key.id) < UIColor.huePrecedence(key: $1.key.id)
    }
    for (worker, amount) in sortedWorkers {
      result.values.append(PieChartDataEntry(value: Double(amount.count), label: worker.description))
      colorSet.append(UIColor.hashColor(parent: worker.id, child: worker.id))
      i += 1
    }
    result.colors = colorSet
    return collections.isEmpty ? nil : PieChartData(dataSet: result)
  }
}
