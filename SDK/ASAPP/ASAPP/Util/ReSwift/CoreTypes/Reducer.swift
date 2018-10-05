//
//  Reducer.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

typealias Reducer<ReducerStateType> =
    (_ change: Change, _ state: ReducerStateType?) -> ReducerStateType
