//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 09.02.2024.
//

import Foundation

protocol StatisticsViewModelProtocol: AnyObject {
    var updateBest: ((Int) -> Void)? { get set }
    var updateCompleted: ((Int) -> Void)? { get set }
    var updateIdeal: ((Int) -> Void)? { get set }
    var updateMiddle: ((Int) -> Void)? { get set }
    
    func updateCompletedTrackersData()
}

final class StatisticsViewModel: StatisticsViewModelProtocol {
    
    var updateBest: ((Int) -> Void)?
    var updateCompleted: ((Int) -> Void)?
    var updateIdeal: ((Int) -> Void)?
    var updateMiddle: ((Int) -> Void)?
    
    private lazy var recordStore: StatisticsRecordStore = StatisticsRecordStore(viewModel: self)
    
    func updateCompletedTrackersData(){
        let records = recordStore.getTrackerRecords()
        
        self.updateCompleted?(records?.count ?? 0)
    }
}
