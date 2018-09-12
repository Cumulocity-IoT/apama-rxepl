# <a name="observable"></a>com.industry.rx_epl.Observable [<>](/src/rx/objects/Observable.mon)
The main class of RxEPL. This event implements the [IObservable](../interfaces/IObservable.md#iobservable) interface and contains all of the various observable construction methods (which all return [IObservable](../interfaces/IObservable.md#iobservable)).

## Methods

All of the public API for this event is static and as such this event should never be manually constructed. This is categorised list of the methods:

* Construction
	* [Create](#create)
	* [Just](#just)
	* [FromValues](#fromvalues)
	* [Interval](#interval)
	* [Range](#range)
	* Repeat
	* Timer
	* FromIterator
	* FromStream
	* FromChannel
	* Start
	* Empty/Never/Error
	* ObserveFromChannel
* Combinatory Operations
	* Merge
	* WithLatestFrom/WithLatestFromToSequence
	* CombineLatest/CombineLatestToSequence
	* Zip/ZipToSequence
	* Concat
	* SequenceEqual
	* Amb

## Construction

<a name="create" href="#create">#</a> .**create**(*`generator:` action<`resolver:` [IResolver](../interfaces/IResolver.md)*) returns [IObservable](../interfaces/IObservable.md#iobservable)\<[T](/docs/api-docs/README.md#wildcard-class-notation)> [<>](/src/rx/operators/internals/Create.mon  "Source")

Create an observable by running the `generator` action whenever a subscription is created.

```javascript
action generator(IResolver r) {
	r.next(1);
	
	on wait(1.0) {
		r.next(2);
	}
	
	on wait(2.0) {
		r.next(3);
		r.complete();
	}
}

Observable.create(generator)
	...

// Output: 1,2,3
```

<a name="just" href="#just">#</a> .**just**(*`value:` [T](/docs/api-docs/README.md#wildcard-class-notation)*) returns [IObservable](../interfaces/IObservable.md#iobservable)\<[T](/docs/api-docs/README.md#wildcard-class-notation)> [<>](/src/rx/operators/internals/Just.mon  "Source")

Create an observable containing just the provided `value`.

```javascript
Observable.just("Hello World")
	...

// Output: "Hello World"
```

<a name="fromvalues" href="#fromvalues">#</a> .**fromValues**(*`values:` sequence<[T](/docs/api-docs/README.md#wildcard-class-notation)>*) returns [IObservable](../interfaces/IObservable.md#iobservable)\<[T](/docs/api-docs/README.md#wildcard-class-notation)> [<>](/src/rx/operators/internals/FromValues.mon  "Source")

Create an observable containing all of the provided `values`. 

Note: [FromValues](#fromvalues) can alternatively be provided with a dictionary or event (rather than a sequence), in which case the observable will contain the values or fields.

```javascript
Observable.fromValues([1,2,3,4])
	...

// Output: 1,2,3,4
```

<a name="interval" href="#interval">#</a> .**interval**(*`seconds:` float*) returns [IObservable](../interfaces/IObservable.md#iobservable)\<integer> [<>](/src/rx/operators/internals/Interval.mon  "Source")

Emit an increasing integer every T `seconds`. The first emission has a value `0` and is emitted at time T.

```javascript
Observable.interval(1.0)
	...

// Output: 0,1,2,3,4...
```

<a name="range" href="#range">#</a> .**range**(*`start:` integer, `end:` integer*) returns [IObservable](../interfaces/IObservable.md#iobservable)\<integer> [<>](/src/rx/operators/internals/Range.mon  "Source")

Emit every integer value from `start` (inclusive) to `end` (inclusive).

Note: Currently only works with ascending values.

```javascript
Observable.range(0,5)
	...

// Output: 0,1,2,3,4,5
```

## Combinatory Operators
