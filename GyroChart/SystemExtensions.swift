//
//  SystemExtensions.swift
//  GyroChart
//
//  Created by Cen Breathnach on 18/03/2017.
//  Copyright © 2017 Cen Breathnach. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
	
	/// Returns the element at the specified index iff it is within bounds, otherwise nil.
	subscript (safe index: Index) -> Generator.Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
