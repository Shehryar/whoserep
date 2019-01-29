//
//  StoreType.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/28/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

/**
 Defines the interface of Stores in ReSwift. `Store` is the default implementation of this
 interface. Applications have a single store that stores the entire application state.
 Stores receive changes and use reducers combined with these changes, to calculate state changes.
 Upon every state update a store informs all of its subscribers.
 */
protocol StoreType: DispatchingStoreType {

    associatedtype State: StateType

    /// The current state stored in the store.
    var state: State! { get }

    /**
     The main dispatch function that is used by all convenience `dispatch` methods.
     This dispatch function can be extended by providing middlewares.
     */
    var dispatchFunction: DispatchFunction! { get }

    /**
     Subscribes the provided subscriber to this store.
     Subscribers will receive a call to `newState` whenever the
     state in this store changes.

     - parameter subscriber: Subscriber that will receive store updates
     - note: Subscriptions are not ordered, so an order of state updates cannot be guaranteed.
     */
    func subscribe<S: StoreSubscriber>(_ subscriber: S) where S.StoreSubscriberStateType == State

    /**
     Subscribes the provided subscriber to this store.
     Subscribers will receive a call to `newState` whenever the
     state in this store changes and the subscription decides to forward
     state update.

     - parameter subscriber: Subscriber that will receive store updates
     - parameter transform: A closure that receives a simple subscription and can return a
       transformed subscription. Subscriptions can be transformed to only select a subset of the
       state, or to skip certain state updates.
     - note: Subscriptions are not ordered, so an order of state updates cannot be guaranteed.
     */
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<State>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState

    /**
     Unsubscribes the provided subscriber. The subscriber will no longer
     receive state updates from this store.

     - parameter subscriber: Subscriber that will be unsubscribed
     */
    func unsubscribe(_ subscriber: AnyStoreSubscriber)

    /**
     Dispatches an change creator to the store. Change creators are functions that generate
     changes. They are called by the store and receive the current state of the application
     and a reference to the store as their input.

     Based on that input the change creator can either return an change or not. Alternatively
     the change creator can also perform an asynchronous operation and dispatch a new change
     at the end of it.

     Example of an change creator:

     ```
     func deleteNote(noteID: Int) -> ChangeCreator {
        return { state, store in
            // only delete note if editing is enabled
            if (state.editingEnabled == true) {
                return NoteDataChange.DeleteNote(noteID)
            } else {
                return nil
            }
        }
     }
     ```

     This change creator can then be dispatched as following:

     ```
     store.dispatch( noteChangeCreator.deleteNote(3) )
     ```

     - returns: By default returns the dispatched change, but middlewares can change the
     return type, e.g. to return promises
     */
    func dispatch(_ changeCreator: ChangeCreator)

    /**
     Dispatches an async change creator to the store. An async change creator generates a
     change creator asynchronously.
     */
    func dispatch(_ asyncChangeCreator: AsyncChangeCreator)

    /**
     Dispatches an async change creator to the store. An async change creator generates an
     change creator asynchronously. Use this method if you want to wait for the state change
     triggered by the asynchronously generated change creator.

     This overloaded version of `dispatch` calls the provided `callback` as soon as the
     asynchronously dispatched change has caused a new state calculation.

     - Note: If the ChangeCreator does not dispatch a change, the callback block will never
     be called
     */
    func dispatch(_ asyncChangeCreator: AsyncChangeCreator, callback: DispatchCallback?)

    /**
     An optional callback that can be passed to the `dispatch` method.
     This callback will be called when the dispatched change triggers a new state calculation.
     This is useful when you need to wait on a state change, triggered by a change (e.g. wait on
     a successful login). However, you should try to use this callback very seldom as it
     deviates slighlty from the unidirectional data flow principal.
     */
    associatedtype DispatchCallback = (State) -> Void

    /**
     A ChangeCreator is a function that, based on the received state argument, might or might not
     create a change.

     Example:

     ```
     func deleteNote(noteID: Int) -> ChangeCreator {
        return { state, store in
            // only delete note if editing is enabled
            if (state.editingEnabled == true) {
                return NoteDataChange.DeleteNote(noteID)
            } else {
                return nil
            }
        }
     }
     ```

     */
    associatedtype ChangeCreator = (_ state: State, _ store: StoreType) -> Change?

    /// AsyncChangeCreators allow the developer to wait for the completion of an async change.
    associatedtype AsyncChangeCreator =
        (_ state: State, _ store: StoreType,
         _ changeCreatorCallback: (ChangeCreator) -> Void) -> Void
}