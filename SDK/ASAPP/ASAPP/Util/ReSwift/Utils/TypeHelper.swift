//
//  TypeHelper.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/27/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

/**
 Method is only used internally in ReSwift to cast the generic `StateType` to a specific
 type expected by reducers / store subscribers.

 - parameter change: A change that will be passed to `handleChange`.
 - parameter state: A generic state type that will be casted to `SpecificStateType`.
 - parameter function: The `handleChange` method.
 - returns: A `StateType` from `handleChange` or the original `StateType` if it cannot be
            casted to `SpecificStateType`.
 */
@discardableResult
func withSpecificTypes<SpecificStateType, Change>(
        _ change: Change,
        state genericStateType: StateType?,
        function: (_ change: Change, _ state: SpecificStateType?) -> SpecificStateType
    ) -> StateType {
        guard let genericStateType = genericStateType else {
            return function(change, nil) as! StateType
        }

        guard let specificStateType = genericStateType as? SpecificStateType else {
            return genericStateType
        }

        return function(change, specificStateType) as! StateType
}
