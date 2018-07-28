//
//  StatSelectionViewController.swift
//  Harvest
//
//  Created by Letanyan Arumugam on 2018/07/07.
//  Copyright © 2018 Letanyan Arumugam. All rights reserved.
//

import Eureka
import SCLAlertView

// swiftlint:disable type_body_length
final class StatSelectionViewController: ReloadableFormViewController {
  var refreshControl: UIRefreshControl?
  
  func customGraph() -> LabelRow {
    return LabelRow { row in
      row.title = "Make Your Own Graph"
    }.cellUpdate { cell, _ in
      cell.textLabel?.textAlignment = .center
      cell.textLabel?.textColor = .addOrchard
    }.onCellSelection { _, _ in
      guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "statSetupViewController") else {
        return
      }
      
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  func customGraphSection() -> Section {
    let result = Section("Your Graphs")
    
    for name in StatStore.shared.statDataNames {
      if let stat = StatStore.shared.getItem(withName: name) {
        result <<< ButtonRow { row in
          row.title = name
        }.cellUpdate { cell, _ in
          cell.textLabel?.textAlignment = .left
          cell.textLabel?.textColor = .black
        }.onCellSelection { _, _ in
          let alert = SCLAlertView(appearance: .optionsAppearance)
          
          alert.addButton("Rename") {
            let infoAlert = SCLAlertView(appearance: .warningAppearance)
            
            let nameTextField = infoAlert.addTextField()
            
            infoAlert.addButton("Rename") {
              StatStore.shared.renameItem(withName: name, toNewName: nameTextField.text ?? "")
            }
            
            infoAlert.addButton("Cancel") {}
            
            infoAlert.showEdit("New Name", subTitle: "Please enter a new name for '\(name)'.")
          }
          
          alert.addButton("Delete") {
            StatStore.shared.removeItem(withName: name)
          }
          
          alert.addButton("Show Graph") {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "statsViewController") else {
              return
            }
            
            guard let svc = vc as? StatsViewController else {
              return
            }
            
            svc.startDate = stat.startDate
            svc.endDate = stat.endDate
            svc.period = stat.period
            svc.stat = Stat.untyped(stat.ids, stat.grouping)
            
            self.navigationController?.pushViewController(svc, animated: true)
          }
          
          alert.addButton("Cancel") {}
          
          alert.showEdit(name, subTitle: "Select an option to do with the graph.")
        }
      }
    }
    
    result <<< customGraph()
    
    return result
  }
  
  // swiftlint:disable function_body_length
  func orchardPerformances() -> [StatEntitySelectionRow] {
    let yesterdaysOrchardPerformance = StatEntitySelectionRow { row in
      row.title = "Yesterday's Orchard Performance"
      let yesterday = Date().yesterday()
      row.startDate = yesterday.0
      row.endDate = yesterday.1
      row.period = .hourly
      row.grouping = .orchard
      row.value = Entities.shared.orchards.map { EntityItem.orchard($0.value) }
    }
    
    let todaysOrchardPerformance = StatEntitySelectionRow { row in
      row.title = "Today's Orchard Performance"
      let today = Date().today()
      row.startDate = today.0
      row.endDate = today.1
      row.period = .hourly
      row.grouping = .orchard
      row.value = Entities.shared.orchards.map { EntityItem.orchard($0.value) }
    }
    
    let lastWeeksOrchardPerformance = StatEntitySelectionRow { row in
      row.title = "Last Week's Orchard Performance"
      let lastWeek = Date().lastWeek()
      row.startDate = lastWeek.0
      row.endDate = lastWeek.1
      row.period = .daily
      row.grouping = .orchard
      row.value = Entities.shared.orchards.map { EntityItem.orchard($0.value) }
    }
    
    let thisWeeksOrchardPerformance = StatEntitySelectionRow { row in
      row.title = "This Week's Orchard Performance"
      let thisWeek = Date().thisWeek()
      row.startDate = thisWeek.0
      row.endDate = thisWeek.1
      row.period = .daily
      row.grouping = .orchard
      row.value = Entities.shared.orchards.map { EntityItem.orchard($0.value) }
    }
    
    let lastMonthsOrchardPerformance = StatEntitySelectionRow { row in
      row.title = "Last Month's Orchard Performance"
      let lastMonth = Date().lastMonth()
      row.startDate = lastMonth.0
      row.endDate = lastMonth.1
      row.period = .weekly
      row.grouping = .orchard
      row.value = Entities.shared.orchards.map { EntityItem.orchard($0.value) }
    }
    
    let thisMonthsOrchardPerformance = StatEntitySelectionRow { row in
      row.title = "This Month's Orchard Performance"
      let thisMonth = Date().thisMonth()
      row.startDate = thisMonth.0
      row.endDate = thisMonth.1
      row.period = .weekly
      row.grouping = .orchard
      row.value = Entities.shared.orchards.map { EntityItem.orchard($0.value) }
    }
    
    let lastYearsOrchardPerformance = StatEntitySelectionRow { row in
      row.title = "Last Year's Orchard Performance"
      let lastYear = Date().lastYear()
      row.startDate = lastYear.0
      row.endDate = lastYear.1
      row.period = .monthly
      row.grouping = .orchard
      row.value = Entities.shared.orchards.map { EntityItem.orchard($0.value) }
    }
    
    let thisYearsOrchardPerformance = StatEntitySelectionRow { row in
      row.title = "This Year's Orchard Performance"
      let thisYear = Date().thisYear()
      row.startDate = thisYear.0
      row.endDate = thisYear.1
      row.period = .monthly
      row.grouping = .orchard
      row.value = Entities.shared.orchards.map { EntityItem.orchard($0.value) }
    }
    
    return [
      todaysOrchardPerformance,
      yesterdaysOrchardPerformance,
      thisWeeksOrchardPerformance,
      lastWeeksOrchardPerformance,
      thisMonthsOrchardPerformance,
      lastMonthsOrchardPerformance,
      thisYearsOrchardPerformance,
      lastYearsOrchardPerformance
    ]
  }
  
  // swiftlint:disable function_body_length
  func workerPerformances() -> [StatEntitySelectionRow] {
    let yesterdaysWorkerPerformance = StatEntitySelectionRow { row in
      row.title = "Yesterday's Worker Performance"
      let yesterday = Date().yesterday()
      row.startDate = yesterday.0
      row.endDate = yesterday.1
      row.period = .hourly
      row.grouping = .worker
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .worker {
          return EntityItem.worker($0.value)
        }
        return nil
      }
    }
    
    let todaysWorkerPerformance = StatEntitySelectionRow { row in
      row.title = "Today's Worker Performance"
      let today = Date().today()
      row.startDate = today.0
      row.endDate = today.1
      row.period = .hourly
      row.grouping = .worker
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .worker {
          return EntityItem.worker($0.value)
        }
        return nil
      }
    }
    
    let lastWeeksWorkerPerformance = StatEntitySelectionRow { row in
      row.title = "Last Week's Worker Performance"
      let lastWeek = Date().lastWeek()
      row.startDate = lastWeek.0
      row.endDate = lastWeek.1
      row.period = .daily
      row.grouping = .worker
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .worker {
          return EntityItem.worker($0.value)
        }
        return nil
      }
    }
    
    let thisWeeksWorkerPerformance = StatEntitySelectionRow { row in
      row.title = "This Week's Worker Performance"
      let thisWeek = Date().thisWeek()
      row.startDate = thisWeek.0
      row.endDate = thisWeek.1
      row.period = .daily
      row.grouping = .worker
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .worker {
          return EntityItem.worker($0.value)
        }
        return nil
      }
    }
    
    let lastMonthsWorkerPerformance = StatEntitySelectionRow { row in
      row.title = "Last Month's Worker Performance"
      let lastMonth = Date().lastMonth()
      row.startDate = lastMonth.0
      row.endDate = lastMonth.1
      row.period = .weekly
      row.grouping = .worker
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .worker {
          return EntityItem.worker($0.value)
        }
        return nil
      }
    }
    
    let thisMonthsWorkerPerformance = StatEntitySelectionRow { row in
      row.title = "This Month's Worker Performance"
      let thisMonth = Date().thisMonth()
      row.startDate = thisMonth.0
      row.endDate = thisMonth.1
      row.period = .weekly
      row.grouping = .worker
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .worker {
          return EntityItem.worker($0.value)
        }
        return nil
      }
    }
    
    let lastYearsWorkerPerformance = StatEntitySelectionRow { row in
      row.title = "Last Year's Worker Performance"
      let lastYear = Date().lastYear()
      row.startDate = lastYear.0
      row.endDate = lastYear.1
      row.period = .monthly
      row.grouping = .worker
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .worker {
          return EntityItem.worker($0.value)
        }
        return nil
      }
    }
    
    let thisYearsWorkerPerformance = StatEntitySelectionRow { row in
      row.title = "This Year's Worker Performance"
      let thisYear = Date().thisYear()
      row.startDate = thisYear.0
      row.endDate = thisYear.1
      row.period = .monthly
      row.grouping = .worker
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .worker {
          return EntityItem.worker($0.value)
        }
        return nil
      }
    }
    
    return [
      todaysWorkerPerformance,
      yesterdaysWorkerPerformance,
      thisWeeksWorkerPerformance,
      lastWeeksWorkerPerformance,
      thisMonthsWorkerPerformance,
      lastMonthsWorkerPerformance,
      thisYearsWorkerPerformance,
      lastYearsWorkerPerformance
    ]
  }
  
  // swiftlint:disable function_body_length
  func foremanPerformances() -> [StatEntitySelectionRow] {
    let yesterdaysForemanPerformance = StatEntitySelectionRow { row in
      row.title = "Yesterday's Foreman Performance"
      let yesterday = Date().yesterday()
      row.startDate = yesterday.0
      row.endDate = yesterday.1
      row.period = .hourly
      row.grouping = .foreman
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .foreman {
          return EntityItem.worker($0.value)
        }
        return nil
        } + [EntityItem.worker(Worker(HarvestUser.current))]
    }
    
    let todaysForemanPerformance = StatEntitySelectionRow { row in
      row.title = "Today's Foreman Performance"
      let today = Date().today()
      row.startDate = today.0
      row.endDate = today.1
      row.period = .hourly
      row.grouping = .foreman
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .foreman {
          return EntityItem.worker($0.value)
        }
        return nil
        } + [EntityItem.worker(Worker(HarvestUser.current))]
    }
    
    let lastWeeksForemanPerformance = StatEntitySelectionRow { row in
      row.title = "Last Week's Foreman Performance"
      let lastWeek = Date().lastWeek()
      row.startDate = lastWeek.0
      row.endDate = lastWeek.1
      row.period = .daily
      row.grouping = .foreman
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .foreman {
          return EntityItem.worker($0.value)
        }
        return nil
      } + [EntityItem.worker(Worker(HarvestUser.current))]
    }
    
    let thisWeeksForemanPerformance = StatEntitySelectionRow { row in
      row.title = "This Week's Foreman Performance"
      let thisWeek = Date().thisWeek()
      row.startDate = thisWeek.0
      row.endDate = thisWeek.1
      row.period = .daily
      row.grouping = .foreman
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .foreman {
          return EntityItem.worker($0.value)
        }
        return nil
      } + [EntityItem.worker(Worker(HarvestUser.current))]
    }
    
    let lastMonthsForemanPerformance = StatEntitySelectionRow { row in
      row.title = "Last Month's Foreman Performance"
      let lastMonth = Date().lastMonth()
      row.startDate = lastMonth.0
      row.endDate = lastMonth.1
      row.period = .weekly
      row.grouping = .foreman
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .foreman {
          return EntityItem.worker($0.value)
        }
        return nil
      } + [EntityItem.worker(Worker(HarvestUser.current))]
    }
    
    let thisMonthsForemanPerformance = StatEntitySelectionRow { row in
      row.title = "This Month's Foreman Performance"
      let thisMonth = Date().thisMonth()
      row.startDate = thisMonth.0
      row.endDate = thisMonth.1
      row.period = .weekly
      row.grouping = .foreman
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .foreman {
          return EntityItem.worker($0.value)
        }
        return nil
      } + [EntityItem.worker(Worker(HarvestUser.current))]
    }
    
    let lastYearsForemanPerformance = StatEntitySelectionRow { row in
      row.title = "Last Year's Foreman Performance"
      let lastYear = Date().lastYear()
      row.startDate = lastYear.0
      row.endDate = lastYear.1
      row.period = .monthly
      row.grouping = .foreman
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .foreman {
          return EntityItem.worker($0.value)
        }
        return nil
      } + [EntityItem.worker(Worker(HarvestUser.current))]
    }
    
    let thisYearsForemanPerformance = StatEntitySelectionRow { row in
      row.title = "This Year's Foreman Performance"
      let thisYear = Date().thisYear()
      row.startDate = thisYear.0
      row.endDate = thisYear.1
      row.period = .monthly
      row.grouping = .foreman
      row.value = Entities.shared.workers.compactMap {
        if $0.value.kind == .foreman {
          return EntityItem.worker($0.value)
        }
        return nil
      } + [EntityItem.worker(Worker(HarvestUser.current))]
    }
    
    return [
      todaysForemanPerformance,
      yesterdaysForemanPerformance,
      thisWeeksForemanPerformance,
      lastWeeksForemanPerformance,
      thisMonthsForemanPerformance,
      lastMonthsForemanPerformance,
      thisYearsForemanPerformance,
      lastYearsForemanPerformance
    ]
  }
  
  override func setUp() {
    let orchardSection = Section("Orchard Comparison")
    for stat in orchardPerformances() {
      orchardSection <<< stat
    }
    
    let workerSection = Section("Worker Comparison")
    for stat in workerPerformances() {
      workerSection <<< stat
    }
    
    let foremanSection = Section("Foreman Comparison")
    for stat in foremanPerformances() {
      foremanSection <<< stat
    }
    
    form
      +++ orchardSection
      
      +++ workerSection
      
      +++ foremanSection
    
      +++ customGraphSection()
  }
  
  override func tearDown() {
    form.removeAll()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
}
