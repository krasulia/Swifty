//
//  FRCTableController.swift
//  Created by Vadim Pavlov on 2/21/17.

import UIKit
import CoreData

open class FRCCellsTableController<Object: NSFetchRequestResult>: CellsTableController<Object>, NSFetchedResultsControllerDelegate {
    
    public let frc: NSFetchedResultsController<Object>
    public var frcUpdate: BatchUpdate?
    public var animation: UITableView.RowAnimation = .automatic

    private var predicateToken: NSKeyValueObservation?
    
    public init(tableView: UITableView, frc: NSFetchedResultsController<Object>, observePredicate: Bool = true, cellDescriptor: @escaping (Object) -> CellDescriptor) {
        self.frc = frc
        let provider = DataProvider(frc: frc)

        super.init(tableView: tableView, provider: provider, cellDescriptor: cellDescriptor)
        frc.delegate = self
        tableView.reloadData()
        
        if observePredicate {
            predicateToken = frc.fetchRequest.observe(\.predicate) { request, change in
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
    }
    
    deinit {
        predicateToken?.invalidate()
    }
    
    open func frcIndexPath(for indexPath: IndexPath) -> IndexPath {
        return indexPath
    }

    // MARK: - NSFetchedResultsControllerDelegate
    open func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        frcUpdate = BatchUpdate()
    }
    
    open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
        if let update = self.frcUpdate {
            self.performBatch(update)
            frcUpdate = nil
        }
        tableView.endUpdates()
    }
    
    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        frcUpdate?.addSection(type: type, index: sectionIndex)
    }
    
    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let old = indexPath.map(frcIndexPath)
        let new = newIndexPath.map(frcIndexPath)
        frcUpdate?.addRow(type: type, indexPath: old, newIndexPath: new)
    }
}

open class FRCTableController<Object: NSFetchRequestResult, Cell: UITableViewCell>: FRCCellsTableController<Object> {
    public init(tableView: UITableView, frc: NSFetchedResultsController<Object>, observePredicate: Bool = true, identifier: String? = nil, register: Register? = nil, configure: @escaping (Cell, Object) -> Void) {
        super.init(tableView: tableView, frc: frc, observePredicate: observePredicate) { object in
            let descriptor = CellDescriptor(identifier: identifier, register: register, configure: { cell in
                configure(cell, object)
            })
            return descriptor
        }
    }
}
