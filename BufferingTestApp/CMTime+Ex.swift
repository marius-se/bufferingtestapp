//
//  CMTime+Ex.swift
//  BufferingTestApp
//
//  Created by Marius Seufzer on 16.06.20.
//  Copyright © 2020 Marius Seufzer. All rights reserved.
//

import Foundation
import AVFoundation

extension CMTime {
    /// Returns sth like "11.3s"
    func formattedString() -> String {
        String(format: "%.1fs", CMTimeGetSeconds(self))
    }
}
