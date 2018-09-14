# <a name="observable"></a>com.industry.rx_epl.Observable [<>](/src/rx/objects/Observable.mon)
The main class of RxEPL. This event implements the [IObservable](../interfaces/IObservable.md#iobservable) interface and contains all of the various observable construction methods (which all return [IObservable](../interfaces/IObservable.md#iobservable)).

## Methods

All of the public API for this event is static and as such this event should never be manually constructed. This is categorised list of the methods:

* [Construction](#construction)
	* [Create](#create)
	* [Just](#just)
	* [FromValues](#fromvalues)
	* [Interval](#interval)
	* [Range](#range)
	* [Repeat](#repeat)
	* [Timer](#timer)
	* [FromIterator](#fromiterator)
	* [FromStream](#fromstream)
	* [FromChannel](#fromchannel)
	* [Start](#start)
	* [Empty](#empty)/[Never](#never)/[Error](#error)
	* [ObserveFromChannel](#observefromchannel)
* [Combinatory Operations](#combinatory-operators)
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

<a name="repeat" href="#repeat">#</a> .**repeat**(*`value:` [T](/docs/api-docs/README.md#wildcard-class-notation), `count:` integer*) returns [IObservable](../interfaces/IObservable.md#iobservable)\<[T](/docs/api-docs/README.md#wildcard-class-notation)> [<>](/src/rx/operators/Repeat.mon  "Source")

Repeat a value a certain number of times.

```javascript
Observable.repeat("a", 5)
	...

// Output: "a","a","a","a","a"
```

<a name="timer" href="#timer">#</a> .**timer**(*`value:` [T](/docs/api-docs/README.md#wildcard-class-notation), `seconds:` float*) returns [IObservable](../interfaces/IObservable.md#iobservable)\<[T](/docs/api-docs/README.md#wildcard-class-notation)> [<>](/src/rx/operators/internals/Timer.mon  "Source")

Emit a value after a period of time elapses.

```javascript
Observable.timer("a", 5.0)
	...

// Output (after 5 seconds): "a"
```

<a name="fromiterator" href="#fromiterator">#</a> .**fromIterator**(*action<> returns any*) returns [IObservable](../interfaces/IObservable.md#iobservable)\<any> [<>](/src/rx/operators/internals/FromIterator.mon  "Source")

Generate values by repeatedly calling an action, until it returns an empty any.

```javascript
integer i := 0;
action iterator() returns any {
	if i < 5 {
		i := i + 1;
		return i;
	}
	return new any;
}

Observable.fromIterator(iterator)
	...

// Output: 0,1,2,3,4
```

<a name="fromstream" href="#fromstream">#</a> .**fromStream**(*stream\<any>*) returns [IObservable](../interfaces/IObservable.md#iobservable)\<any> [<>](/src/rx/operators/internals/FromStream.mon  "Source")

Convert a stream to an observable.

Note: To convert a `stream<X>` to `stream<any>` use: `from a in strm select <any> a`

```javascript
// Example stream from listener
stream<integer> strm := from d in all Data() select d.intValue;

// Converting a stream to an observable
Observable.fromStream(from v in strm select <any> v)
	...
```

<a name="fromchannel" href="#fromchannel">#</a> .**fromChannel**(*`channelName:` string*) returns [IObservable](../interfaces/IObservable.md#iobservable)\<any> [<>](/src/rx/operators/internals/FromChannel.mon  "Source")

Take everything sent to a channel as the source of an Observable.

Primitive values can be wrapped inside [WrappedAny(...)](../utilities/WrappedAny.md#wrappedany) and will be automatically unwrapped.

Note: Receiving the events is done in a separate context and forwarded to the creating context. As such, this source starts asynchronously and will miss events until the channel receiver has spawned (generally within 0.5 seconds).

```javascript
on wait(1.0) {
	send com.industry.rx_epl.WrappedAny(1) to "My Channel";
	send com.industry.rx_epl.WrappedAny(2) to "My Channel";
	send MyEvent(3) to "My Channel";
}

Observable.fromChannel("My Channel")
	...

// Output: 1,2,MyEvent(3)
```

<a name="start" href="#start">#</a> .**start**(*`generator:` action<> returns any*) returns [IObservable](../interfaces/IObservable.md#iobservable)\<any> [<>](/src/rx/operators/internals/Start.mon  "Source")

Run an action once to generate a single value for an observable.

```javascript
action generator() returns any {
	return 1.0;
}

Observable.start(generator)
	...

// Output: 1.0
```

<a name="empty" href="#empty">#</a> .**empty**() returns [IObservable](../interfaces/IObservable.md#iobservable)\<any> [<>](/src/rx/operators/internals/EmptyNeverError.mon  "Source")

Return an observable that completes with no values.

```javascript
Observable.empty()
```

<a name="never" href="#never">#</a> .**never**() returns [IObservable](../interfaces/IObservable.md#iobservable)\<any> [<>](/src/rx/operators/internals/EmptyNeverError.mon  "Source")

Return an observable that **does not** complete and emits no values.

```javascript
Observable.never()
```

<a name="error" href="#error">#</a> .**error**() returns [IObservable](../interfaces/IObservable.md#iobservable)\<any> [<>](/src/rx/operators/internals/EmptyNeverError.mon  "Source")

Return an observable that provides an error.

```javascript
Observable.error()
```

<a name="observefromchannel" href="#observefromchannel">#</a> .**observeFromChannel**(*`channelName:` string*) returns [IObservable](../interfaces/IObservable.md#iobservable)\<any> [<>](/src/rx/operators/internals/ObserveFromChannel.mon  "Source")

[ObserveToChannel](../interfaces/IObservable#observetochannel) and ObserveFromChannel are useful for sending data between different monitor instances which may or may not be on different contexts.

```javascript
// Ideally should dispose of this when all subscribers are finished (if ever)
IDisposable d := Observable.interval(1.0).observeToChannel("channelName");

// This could be in a different monitor
ISubscription s := Observable.observeFromChannel("channelName")
        .subscribe(Subscriber.create().onNext(printValue));
        
// Output: 0, 1, 2, 3
```

## Combinatory Operators
