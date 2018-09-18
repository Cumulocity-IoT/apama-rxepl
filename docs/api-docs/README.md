
# API Documentation

## Constructors
- com.industry.rx_epl.[Observable](constructors/Observable.md#observable)
- com.industry.rx_epl.Subject
- com.industry.rx_epl.BehaviourSubject
- com.industry.rx_epl.ReplaySubject
- com.industry.rx_epl.Subscriber 

## Interfaces
- com.industry.rx_epl.[IObservable](interfaces/IObservable.md#iobservable)
- com.industry.rx_epl.[ISubject](interfaces/ISubject.md#isubject)
- com.industry.rx_epl.[ISubscription](interfaces/ISubscription.md#isubscription)
- com.industry.rx_epl.[IDisposable](interfaces/IDisposable.md#idisposable)
- com.industry.rx_epl.IResolver

## Utilities

- com.industry.rx_epl.DisposableStream
- com.industry.rx_epl.TimeInterval
- com.industry.rx_epl.TimestampedValue
- com.industry.rx_epl.WrappedAny

## Operators
- com.industry.rx_epl.operators.[**\***](interfaces/IObservable.md#operators-and-methods)

All of the standard operators (except `publish`, `connect`, `refCount`, `share`...) can be used in two ways:

**Chaining** - Accessible from the [IObservable](interfaces/IObservable.md#iobservable) interface.
```javascript
Observable.fromValues([1,2,3])
	.map(multiplyBy10)
	.reduce(sumValues)
	...
```
**Piping** - Accessible via the `com.industry.rx_epl.operators.*` sub-package, and used via the [.let(...)](interfaces/IObservable.md#let) and [.pipe(...)](interfaces/IObservable.md#pipe) operators.
```javascript
using com.industry.rx_epl.operators.Map;
using com.industry.rx_epl.operators.Reduce;

Observable.fromValues([1,2,3])
	.let(Map.create(multiplyBy10))
	.let(Reduce.create(sumValues))
	...

Observable.fromValues([1,2,3])
	.pipe([
		Map.create(multiplyBy10),
		Reduce.create(sumValues)
	])
	...
```

For a list of operators see: [IObservable](interfaces/IObservable.md#iobservable)


## Wildcard Class Notation

In the API documentation you will see notation like:

- **action<[T](/#wildcard-class-notation)> returns [T](/#wildcard-class-notation)**

This means any of the following would be acceptable:

- **action\<integer> returns integer**<br/>
- **action\<float> returns float**<br/>
- **action\<string> returns string**

But, the following would not be acceptable:

- **action\<float> returns integer**<br/>

However, it would be acceptable if the definition was:

- **action<[T1](/#wildcard-class-notation)> returns [T2](/#wildcard-class-notation)**

In practice this is frequently used with any operators that take actions:

.**map**(*action<`value:` [T1](#wildcard-class-notation)> returns [T2](#wildcard-class-notation)*) returns [IObservable](#iobservable)<[T2](#wildcard-class-notation)>

Here we can see that map takes an argument which is an action. The action must have 1 argument (of any type) and return a value (of any type). 
The return type of the action determines the return type of the IObservable.

As such, any action that meets the criteria is an acceptable action to use with the map operator:

```javascript
action multiplyIntegerBy10(integer value) returns integer {
  return value * 10;
}
```
```javascript
action convertValueToString(any value) returns string {
  return value.valueToString();
}
```

This is possible because the real method signature of `.map(...)` is:

.**map**(*any*) returns [IObservable](#iobservable)

However, there are strict runtime checks to make sure you don't provide anything invalid (eg. a string).
