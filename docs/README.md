

# RxEPL 
* [Installation](#install)
* [Introduction to ReactiveX and Observables](#intro) 
* Overview
	* [Observable](#observable)
		* [Subscribing](#subscribing)
		* [Operators](#chaining)
	* [Subject](#subject)
	* [Debugging](#debugging)
	* [Multithreading](#multithreading)
	* [Reusability: Build your own Observable Operator](#reusability)
* [Help and Other Resources](#other)
## <a id="install"></a>Installation

## <a id="intro"></a>ReactiveX: an Introduction
ReactiveX is a framework. It has libraries which implement the framework in a [most](http://reactivex.io/languages.html) of the major programming languages.

The main object in ReactiveX is the Observable:
```javascript
IObservable temperatureBreaches := Observable.fromChannel("TemperatureSensor") 	// Get all of the events being sent to this channel
						   .pluck("temperature") 								// Get the temperature value
						   .filter(aboveThreshold); 							// Filter to only the temperatures we want

ISubscription generateAlerts := temperatureBreaches.subscribe(Subscriber.create().onNext(generateAlert)); // Generate an alert
```
Observable Operators are chainable
Features:
* [Chainable](#chaining) (without "callback hell"!)
* [Error handling](#errors)
* ["Easy" multithreading](#multithreading)

For a comprehensive introduction to ReactiveX and Observables see the [ReactiveX Website](http://reactivex.io/intro.html).
## <a id="observable"></a>Observable
```javascript
using com.industry.rx_epl.IObservable;
using com.industry.rx_epl.Observable;
```
### Constructing an Observable
Creating an Observable is usually the starting point of an Observable chain (See also: [Subject](#subject))
```javascript
IObservable o := Observable.just("Hello World");
            o := Observable.fromValues([<any>"a",1,MyEvent("abc")]);
            o := Observable.range(0,5);
            o := Observable.interval(1.0);
            o := Observable.fromChannel("MyChannel");
            o := Observable.fromStream(from e in all E() select <any> e);
```

### <a id="subscribing"></a>Subscribing - Receiving data
#### onNext

```javascript
IObservable o := Observable.interval(1.0);
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue));
// Output: 0, 1, 2, 3...
```

```javascript
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue));

action printValue(any value) {
    print value.valueToString();
}
```

#### onComplete
```javascript
IObservable o := Observable.just("Hello World");
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue).onComplete(printDone));
// Output: Hello World, Done
```

```javascript
ISubscription s := o.subscribe(Subscriber.create().onComplete(printDone));

action printDone() {
    print "Done";
}
```
#### onError
```javascript
IObservable o := Observable.error();
ISubscription s := o.subscribe(Subscriber.create().onError(printError));
// Output: com.apama.exceptions.Exception(...)
```

```javascript
ISubscription s := o.subscribe(Subscriber.create().onError(printError));

action printError(any e) {
    print e.valueToString();
}
```
### <a id="chaining"></a>Operators
All of the built-in operators are accessible directly from the IObservable interface:
```javascript
IObservable o := Observable.range(0,20)
						   .skip(1)
						   .take(3)
						   .map(multiplyBy10);
							
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue).onComplete(printDone));
// Output: 1, 2, 3, Done
```
They are also accessible via a "pure function" pipe, and can be combined with custom operators:
```javascript
IObservable o := Observable.range(0,20)
						   .let(Skip.create(1))  // Use a single operator
						   .pipe([				 // Chain multiple operators
								Take.create(3),
								Map.create(multiplyBy10),
								MyCustomOperator.create(123.4)
							]);
							
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue).onComplete(printDone));
// Output: 1, 2, 3, Done
```

Which you choose to use is up to you.

There are far too many operators to go through every one here, but there is a really handy decision tree in the [external links section](#other) to help you find the one you need. The ApamaDoc lists all of the operators.

## <a id="errors"></a>Error Handling
### onError
```javascript
ISubscription s := o.subscribe(Subscriber.create().onError(printError));

action printError(any e) {
    print e.valueToString();
}
```
### catchError
```javascript
IObservable o; // = 0, 1, Error
ISubscription s := o 
                    .catchError(Observable.just("Use this instead"))
                    .subscribe(Subscriber.create().onNext(printValue));
// Output: 0, 1, Use this instead
```
### retry
```javascript
IObservable coldObservable; // = 0, 1, Error
ISubscription s := coldObservable 
                    .retry(1)
                    .subscribe(Subscriber.create().onNext(printValue).onError(printError));
// Output: 0, 1, 0, 1, Error
```
```javascript
IObservable hotObservable; // = 0, 1, Error, 2, 3
ISubscription s := hotObservable 
                    .retry(1)
                    .subscribe(Subscriber.create().onNext(printValue).onError(printError).onComplete(printComplete));
// Output: 0, 1, 2, 3
```

## Multithreading
### observeOn
```javascript
// Ideally should dispose of this when the spawned context is done processing (if ever)
IDisposable d := Observable.interval(1.0).observeOn(doSomething, context("A specific context", false));

action doSomething(IObservable source) {
    // This part will run on a different context
    ISubscription s := source.take(4)
        .subscribe(Subscriber.create().onNext(printValue).onError(printError).onComplete(printComplete));
}
// Output from "A specific context": 0, 1, 2, 3
```
### observeToChannel, observeFromChannel
```javascript
// Ideally should dispose of this when all subscribers are finished (if ever)
IDisposable d := Observable.interval(1.0).observeToChannel("channelName");

// This could be in a different monitor
ISubscription s := Observable.observeFromChannel("channelName")
        .subscribe(Subscriber.create().onNext(printValue).onError(printError).onComplete(printComplete));
// Output: 0, 1, 2, 3
```
### pipeOn
```javascript
// Values start on the main context
ISubscription s := Observable.interval(1.0)
                            // Send to a different context to do the heavy lifting
                            .pipeOn([Map.create(multiplyBy10)], context("A specific context", false));
                            // Back on the main context for the output
                            .subscribe(Subscriber.create().onNext(printValue));
// Output: 0, 10, 20, 30...
```
### complexPipeOn
```javascript
// Values start on the main context
ISubscription s := Observable.interval(1.0)
                            // Send to a different context to do the heavy lifting
                            .complexPipeOn(doSomething, context("A specific context", false));
                            // Back on the main context for the output
                            .subscribe(Subscriber.create().onNext(printValue));
                            
action doSomething(IObservable o) returns IObservable {
    return o.map(multiplyBy10)
}
// Output: 0, 10, 20, 30...
```
### subscribeOn
```javascript
ISubscription s := Observable.interval(1.0)
                            .map(multiplyBy10)
                            // Move all processing to a different context (including the .map and the observable source)
                            .subscribeOn(Subscriber.create().onNext(printValue), context("A specific context", false));
// Output from "A specific context": 0, 10, 20, 30...
```

## Publishing and Sharing
```javascript
IObservable o := Observable.interval(1.0);
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue));
// Output: 0, 1, 2, 3...
on wait(2.0) {
    ISubscription s2 := o.subscribe(Subscriber.create().onNext(printValue));
    // Output: 0, 1, 2, 3...  What?!
}
```
```javascript
IObservable o := Observable.interval(1.0).publish();
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue));
IDisposable d := o.connect();
// Output: 0, 1, 2, 3...
on wait(2.0) {
    ISubscription s2 := o.subscribe(Subscriber.create().onNext(printValue));
    // Output: 2, 3...
}
```
```javascript
IObservable o := Observable.interval(1.0).publish().refCount();
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue));
// Output: 0, 1, 2, 3...
on wait(2.0) {
    ISubscription s2 := o.subscribe(Subscriber.create().onNext(printValue));
    // Output: 2, 3...
}
```
```javascript
IObservable o := Observable.interval(1.0).share();
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue));
// Output: 0, 1, 2, 3...
on wait(2.0) {
    ISubscription s2 := o.subscribe(Subscriber.create().onNext(printValue));
    // Output: 2, 3...
}
```
```javascript
IObservable o := Observable.interval(1.0).publish();
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue));
// Output: 0, 1, 2, 3...
on wait(2.0) {
    ISubscription s2 := o.subscribe(Subscriber.create().onNext(printValue));
    // Output: 0, 1, 2, 3...
    IDisposable d := o.connect();
}
```
## <a id="subject"></a>Subject

### Constructing a Subject

## <a id="debugging"></a>Debugging
### do
```javascript
IObservable o := Observable.interval(1.0);
ISubscription s := o.take(5);
                    .do(Subscriber.create().onNext(printValue).onError(printError).onComplete(printComplete));
                    .map(modifyTheData)
                    .subscribe(Subscriber.create());
// Output: 0, 1, 2, 3, 4, Done
```

## <a id="reusability"></a>Reusability: Build your own Observable Operator
Lets say you have the following:
```javascript
observable
   .pluck("temperature")
   .filter(aboveThreshold);
```
but you want it to be reusable.

There are several options:

### Option 1: Wrap into an action - Good
```javascript
action tempTooHigh(IObservable source) returns IObservable {
	return observable
			   .pluck("temperature")
			   .filter(aboveThreshold);
}
```

You might be tempted just to call that action eg. `tempTooHigh(myObservableTemps)`, but **don't**, there's a better way:
```javascript
IObservable o := myObservableTemps
					.complexPipe(tempTooHigh);
```
Why is this better? It is much more obvious what order the chain is processing in.
### Option 2: Convert to pipe - Better
```javascript
sequence<action<action<IObserver> returns ISubscription> > returns action<IObserver> returns ISubscription> 
	tempTooHigh := [Pluck.create("temperature"), Filter.create(outsideThreshold)];
	
IObservable o := myObservableTemps
   .pipe(tempTooHigh);
```
### Option 3:  Create a custom pipe - Best
```javascript
event TempTooHigh {	
	static action create() returns action<action<IObserver> returns ISubscription> returns action<IObserver> returns ISubscription {
		return Pipe.create([Pluck.create("temperature"), Filter.create(outsideThreshold)]);
	}
}
	
IObservable o := myObservableTemps
   .pipe([TempTooHigh.create()]);

// or

IObservable o := myObservableTemps
   .let(TempTooHigh.create());
```
## <a id="other"></a>Help and Other Resources
**[ReactiveX Website](http://reactivex.io/)** - A Great place to get info about the background to the framework.
**[Decision Tree Of Observables](http://reactivex.io/documentation/operators.html#tree)** - Don't know which operator to use? Follow this
**[RxMarbles](http://rxmarbles.com/)** - An interactive tool to play with observable operators