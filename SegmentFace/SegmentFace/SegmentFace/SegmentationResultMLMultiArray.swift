//
//  SegmentationResultMLMultiArray.swift
//  SegmentFace
//
//  Created by Marco Perotti on 09/02/21.
//

import CoreML

class SegmentationResultMLMultiArray{
    let mlMultiArray: MLMultiArray
    let segmentationmapWidthSize: Int
    let segmentationMapHeightSize: Int
    
    init(mlMultiArray: MLMultiArray){
       self.mlMultiArray = mlMultiArray
        self.segmentationmapWidthSize = self.mlMultiArray.shape[0].intValue
        self.segmentationMapHeightSize = self.mlMultiArray.shape[1].intValue
        //print("MlMultishape: \(self.mlMultiArray.shape)")
        //print("MlMultiCount: \(self.mlMultiArray.count)")

    }
    
    subscript(columnIndex: Int, rowIndex: Int) -> NSNumber{
        let index = columnIndex*(segmentationMapHeightSize) + rowIndex
        return mlMultiArray[index]
    }
    
    
}

