import Foundation

/**
 Defines the interface of a dispatching, stateless Store in ReSwift. `StoreType` is
 the default usage of this interface. Can be used for store variables where you don't
 care about the state, but want to be able to dispatch changes.
 */
protocol DispatchingStoreType {

    /**
     Dispatches an change. This is the simplest way to modify the store's state.

     Example of dispatching an change:

     ```
     store.dispatch( CounterChange.IncreaseCounter )
     ```

     - parameter change: The change that is being dispatched to the store
     - returns: By default returns the dispatched change
     */
    func dispatch(_ change: Change)
}
