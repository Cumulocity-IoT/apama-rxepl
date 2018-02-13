
# RxEPL

## Installation

## ReactiveX an Introduction

## Observable

### Constructing an Observable
```javascript
IObservable o := Observable.just("Hello World");
            o := Observable.fromValues([<any>0,1,2,3]);
            o := Observable.interval(1.0);
            o := Observable.fromChannel("MyChannel");
            o := Observable.fromStream(from e in all E() select <any> e);
```

### Subscribing - Receiving data
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
## Error Handling
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

## Subject

### Constructing a Subject

## Debugging
### do
```javascript
IObservable o := Observable.interval(1.0)
ISubscription s := o.take(5)
                    .do(Subscriber.create().onNext(printValue).onError(printError).onComplete(printComplete));
                    .map(modifyTheData)
                    .subscribe(Subscriber.create());
// Output: 0, 1, 2, 3, 4, Done
```
