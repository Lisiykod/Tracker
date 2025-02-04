//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Olga Trofimova on 27.01.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

class TrackerTests: XCTestCase {

    func testViewController() {
        let trackersViewController = TrackersViewController()
        assertSnapshots(of: trackersViewController, as: [.image])
    }

}
