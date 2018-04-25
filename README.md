<!--- 
Copyright 2018 Software AG

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->

# RxEPL - Observables in EPL
## Contents
* [Installation](#install)
* [Introduction to ReactiveX and Observables](#intro) 
* Main
    * [Package Structure](#packages)
    * [Examples](#examples)
    * [Observable](#observable)
        * [Creating](#observable-construction)
        * [Subscribing](#subscribing)
        * [Operators](#operators)
        * [Joining & Combining](#combining)
        * [Error Handling](#errors)
        * [Publishing/Sharing and Multicasting](#multicasting)
    * [Subject](#subject)
        * [Types](#subject-types)
        * [Creating](#subject-construction)
        * [Sending Data](#subject-sending)
    * [Interoperability](#interop)
        * [Streams](#streams)
        * [Channels](#channels)
    * [Multithreading](#multithreading)
    * [Debugging](#debugging)
    * [Reusability: Build your own Operator](#reusability)
* [Gotchas](#gotchas)
	* [Multiple Subscribers](#gotcha-multiple-subscribers)
    * [Publish/Share with SubscribeOn](#gotcha-subscribe-on)
* [Help and Other Resources](#other)
## <a id="install"></a>Installation
### 1. Installing files
Copy the folders contained inside `CopyContentsToApamaInstallDir` into the Apama install directory (Usually `C:\SoftwareAG\Apama` on Windows or `/opt/softwareag/apama` on Unix), merging them with what is already there.
### 2. Adding to Designer
1. From designer right click on your project in `Project Explorer`
2. Select `Apama` from the drop down menu;
3. Select `Add Bundle`
4. Scroll down to `Standard bundles` and select `RxEpl`
5. Click `Ok`

## <a id="intro"></a>ReactiveX: an Introduction
ReactiveX is a framework designed to handle streams of data like water through pipes. It has libraries which implement the framework in a [most](http://reactivex.io/languages.html) major programming languages.
```javascript
IObservable temperatureBreaches := 
    Observable.fromChannel("TemperatureSensor") // Get all of the events being sent to this channel
              .pluck("temperature")             // Get the temperature value
              .filter(aboveThreshold);          // Filter to only the temperatures we want
              
// Generate an alert
ISubscription generateAlerts := temperatureBreaches.subscribe(Subscriber.create().onNext(generateAlert)); 
```
Features:
* Functional Programming
* [Chainable Operators](#operators) (without "callback hell"!)
* [Error handling](#errors)
* ["Easy" multithreading](#multithreading)

For a comprehensive introduction to ReactiveX and Observables see the [ReactiveX Website](http://reactivex.io/intro.html).
## <a id="packages"></a>Package Structure
**Interfaces:**
`com.industry.rx_epl.IObservable` - The main observable interface, returned after calling an operator or constructor (See [Observable](#observable))
`com.industry.rx_epl.ISubject` - The subject interface, returned from construction of a subject (see [Subject](#subject))
`com.industry.rx_epl.ISubscription` - Returned by `.subscribe()` allows unsubscription
`com.industry.rx_epl.IDisposable` - Sometimes a listener has to be created that this library doesn't know when to tear down, in that case it returns an `IDisposable` and should be torn down by the user if/when all subscribers are done (see [Multithreading](#multithreading))
`com.industry.rx_epl.IResolver` - Similar to a subject has next, error, complete methods. Used in [Observable.create(...)](#observable-construction)

**Constructors:**
`com.industry.rx_epl.Observable` - The event from which to construct an IObservable (See [Observable](#observable))
`com.industry.rx_epl.Subject` - A simple subject, allowing next, error, complete events to be sent  (see [Subject](#subject))
`com.industry.rx_epl.BehaviourSubject` - A subject that always repeats the most recent value to a new subscriber (see [Subject](#subject))
`com.industry.rx_epl.Subscriber` - A subscriber. Defines handling for onNext, onError, onComplete (see [Subscribing](#subscribing))

**Operators:**
`com.industry.rx_epl.operators.*` - All pipeable operators (See [Operators](#operators). The ApamaDoc contains a full list)
## <a id="examples"></a>Examples
There are several examples that ship with the source code. These are located in the `Examples` folder.
## <a id="observable"></a>Observable
### <a id="observable-construction"></a>Constructing an Observable
Creating an Observable is usually the starting point of an Observable chain (See also: [Subject](#subject))
```javascript
IObservable o := Observable.just("Hello World");
            o := Observable.fromValues([<any> 0, 1, 2, "Hello", "World"]);
            o := Observable.range(0,5);
            o := Observable.interval(1.0);
            o := Observable.fromChannel("MyChannel");
            o := Observable.fromStream(from e in all E() select <any> e);
            o := Observable.create(generator);

action generator(IResolver r) {
    r.next("Hello");
    r.complete();
}
```

### <a id="subscribing"></a>Subscribing - Receiving data
Subscribing is the main way to extract information from an observable pipe.
**Important To Note:** Every subscriber gets it's own pipe to the observable source so operators are run once per subscription. To avoid this use [publish or share](#multicasting).

**onNext** - Used to get every data point from the pipe
```javascript
IObservable o := Observable.interval(1.0);
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue));
// Output: 0, 1, 2, 3...

action printValue(any value) {
    print value.valueToString();
}
```
**onComplete** - Called when the pipe is closing (not all observables complete)
```javascript
IObservable o := Observable.just("Hello World");
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue).onComplete(printDone));
// Output: Hello World, Done

action printDone() {
    print "Done";
}
```
**onError** - Called when the pipe is closing due to an error
```javascript
IObservable o := Observable.error();
ISubscription s := o.subscribe(Subscriber.create().onError(printError));
// Output: com.apama.exceptions.Exception(...)

action printError(any e) {
    print e.valueToString();
}
```
### <a id="operators"></a>Operators
All of the built-in operators are accessible directly from the IObservable interface:
```javascript
IObservable o := Observable.range(0,20)
                           .skip(1)
                           .take(3)
                           .map(multiplyBy10);
                            
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue).onComplete(printDone));
// Output: 1, 2, 3, Done
```
They are also accessible via a "pure function" pipe, and can then be combined with custom operators:
```javascript
IObservable o := Observable.range(0,20)
                           .let(Skip.create(1))  // Use a single operator
                           .pipe([                 // Chain multiple operators
                                Take.create(3),
                                Map.create(multiplyBy10),
                                MyCustomOperator.create(123.4)
                            ]);
                            
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue).onComplete(printDone));
// Output: 1, 2, 3, Done
```
Which you choose to use is up to you.

There are far too many operators to go through every one here, but there is a really handy decision tree in the [external links section](#other) to help you find the one you need. The ApamaDoc lists all of the operators.

## <a id="combining"></a>Joining and Combining
**Merge** - Combine all values from multiple observables onto one observable
```javascript
IObservable o1 := Observable.interval(1.0);
IObservable o2 := Observable.interval(1.5);

IObservable combined := Observable.merge([o1, o2]);
// Output: 0, 0, 1, 2, 1, 3, 2, 4...
```
**Concat** - Append the values from one observable to the values from another
```javascript
IObservable o1 := Observable.interval(1.0).take(3);
IObservable o2 := Observable.interval(1.5);

IObservable combined := Observable.concat([o1, o2]);
// Output: 0, 1, 2, 0, 1, 2...
```
**CombineLatest** - Every time an event is received combine it with the latest from every other observable
```javascript
IObservable o1 := Observable.interval(1.0);
IObservable o2 := Observable.interval(1.5);

IObservable combined := Observable.combineLatest([o1, o2], toIntSequence);
// Output: [0,0], [1,0], [2,0], [2,1]...
// @Time:  1.0  , 2.0  , 3.0  , 3.0
```
**WithLatestFrom** - Every time an event is receive on the main observable combine it with the latest from every other observable
```javascript
IObservable o1 := Observable.interval(1.0);
IObservable o2 := Observable.interval(1.5);

IObservable combined := o1.withLatestFrom([o2], toIntSequence);
// Output: [1,0], [2,1], [2,1]...
// @Time:  2.0  , 3.0  , 4.0
```
**Zip** - Sequentially combine each event with an event from every other observable
```javascript
IObservable o1 := Observable.interval(1.0);
IObservable o2 := Observable.interval(1.5);

IObservable combined := Observable.zip([o1, o2], toIntSequence);
// Output: [0,0], [1,1], [2,2], [3,3]...
// @Time:  1.5  , 3.0  , 4.5  , 6.0
```
## <a id="errors"></a>Error Handling
Observables handle errors in almost exactly the same they handle "complete" events. They are passed along the chain of observers until they are handled. If they are not handled by the final subscriber then the subscriber will throw an exception.
### Subscriber.onError
Subscribing to the error output of an observable allows a subscriber to manually handle errors
```javascript
ISubscription s := o.subscribe(Subscriber.create().onError(printError));

action printError(any e) {
    log e.valueToString() at ERROR;
}
```
### IObservable.catchError
Catching errors allows an observable chain to substitute an alternative observable source in the event of an error.
```javascript
IObservable o; // = 0, 1, Error
ISubscription s := o 
                    .catchError(Observable.just("Use this instead"))
                    .subscribe(Subscriber.create().onNext(printValue));
// Output: 0, 1, Use this instead
```
### IObservable.retry
Retry instructs the observable to reconnect to the source in the event of an error.
```javascript
IObservable hotObservable; // = 0, 1, Error, 2, 3
ISubscription s := hotObservable 
                    .retry(1)
                    .subscribe(Subscriber.create()
                                         .onNext(printValue)
                                         .onError(printError)
                                         .onComplete(printComplete));
// Output: 0, 1, 2, 3
```
## <a id="interop"></a>Interoperability
### <a id="streams"></a>Streams
**Receiving from a stream**
```javascript
// Receiving events 
IObservable o := Observable.fromStream(from e in all MyEventType() select <any> e);

// Receiving values
using com.industry.rx_epl.WrappedAny;
IObservable o := Observable.fromStream(from e in all WrappedAny() select e.value);
```
**Output to a stream**
```javascript
IObservable o := Observable.interval(1.0);

DisposableStream strm := o.toStream();

from value in strm.getStream() select value {
    log value;
}

// When done, the stream should be disposed
strm.dispose();
```
### <a id="channels"></a>Channels
**Receiving from a channel**
```javascript
// Receiving events 
IObservable o := Observable.fromChannel("myChannel");

send MyEvent("abc", 123) to "myChannel";

// Values sent in a WrappedAny are automatically unwrapped
using com.industry.rx_epl.WrappedAny;
send WrappedAny("abc") to "myChannel";
```
**Output to a channel**
```javascript
IObservable o := Observable.interval(1.0);

Subscription s := o.subscribe(Subscriber.create().onNext(sendToChannel));

action sendToChannel(any value) {
    send value to "myChannel";
}
```
## Multithreading
Multithreading allows complex or slow processing to be handled asynchronously on a different context.
### observeOn
Observe on is useful when you want the subscription and some of the processing to be done on a different thread. The connection to the original observable is still done on the main context and all data is forwarded to the other context.
```javascript
// Ideally should dispose of this when the spawned context is done processing (if ever)
IDisposable d := Observable.interval(1.0).observeOnNew(doSomething);

action doSomething(IObservable source) {
    // This part will run on a different context
    ISubscription s := source.take(4)
        .subscribe(Subscriber.create().onNext(printValue));
}
// Output from "A specific context": 0, 1, 2, 3
```
### observeToChannel, observeFromChannel
ObserveToChannel and ObserveFromChannel are useful for sending data between different monitor instances which may or may not be on different contexts.
```javascript
// Ideally should dispose of this when all subscribers are finished (if ever)
IDisposable d := Observable.interval(1.0).observeToChannel("channelName");

// This could be in a different monitor
ISubscription s := Observable.observeFromChannel("channelName")
        .subscribe(Subscriber.create().onNext(printValue));
// Output: 0, 1, 2, 3
```
### pipeOn
PipeOn allows part of the processing in a chain to be done on a different context. Data is received on the main context, forwarded to another context for processing, and finally forwarded back to the main context for subscription.
```javascript
// Values start on the main context
ISubscription s := Observable.interval(1.0)
                            // Send to a different context to do the heavy lifting
                            .pipeOnNew([Map.create(multiplyBy10)]);
                            // Back on the main context for the output
                            .subscribe(Subscriber.create().onNext(printValue));
// Output: 0, 10, 20, 30...
```
### complexPipeOn
Much the same as PipeOn, ComplexPipeOn allows part of an observable chain to be processed on a separate context.
```javascript
// Values start on the main context
ISubscription s := Observable.interval(1.0)
                            // Send to a different context to do the heavy lifting
                            .complexPipeOnNew(doSomething);
                            // Back on the main context for the output
                            .subscribe(Subscriber.create().onNext(printValue));
                            
action doSomething(IObservable o) returns IObservable {
    return o.map(multiplyBy10)
}
// Output: 0, 10, 20, 30...
```
### subscribeOn
SubscribeOn will move an entire chain (from source to subscription) onto another context. There are a couple of [Gotchas](#gotchas) with this when used with publishing and sharing.
```javascript
ISubscription s := Observable.interval(1.0)
                             .map(multiplyBy10)
                             // Move all processing to a different context 
                             // (including the .map and the observable source)
                             .subscribeOnNew(Subscriber.create()
                                                              .onNext(printValue));
// Output from "A specific context": 0, 10, 20, 30...
```

## <a id="multicasting"></a>Publishing and Sharing
Publishing and Sharing are methods of converting an Observable a multicast emitter. 

By default when a normal observable is subscribed to an entirely new processing chain is created (one for each subscriber), this can result in some unexpected behaviour:
```javascript
IObservable o := Observable.interval(1.0);
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue));
// Output: 0, 1, 2, 3...
on wait(2.0) {
    ISubscription s2 := o.subscribe(Subscriber.create().onNext(printValue));
    // Output: 0, 1, 2, 3...  What?!
}
```
The first subscriber creates it's own interval, and so does the second one. These are not linked.
### Publish
Publish allows a single observable subscription to be shared among various other subscribers. The upstream subscription is only created when connect is called so downstreams will not receive values until then.
```javascript
IObservable o := Observable.interval(1.0).publish();
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue));
IDisposable d := o.connect();
// Output: 0, 1, 2, 3...
on wait(2.0) {
    ISubscription s2 := o.subscribe(Subscriber.create().onNext(printValue));
    // Output: 2, 3... Connected 2s after .connect() was called so missed 2 values
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
### <a id="refcount"></a>Publish RefCount
Manually connecting to a published observable can be a pain. RefCount will automatically connect to a published observable when the first subscriber subscribes. It keeps a count of the number of subscribers so that when the count drops to zero it can disconnect. A subscription after disconnection will result in a re-connection.
publish().refCount() is so common that it has a shorthand [.share()](#share)
```javascript
IObservable o := Observable.interval(1.0).publish().refCount(); // can be replaced with .share()
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue));
// Output: 0, 1, 2, 3...
on wait(2.0) {
    ISubscription s2 := o.subscribe(Subscriber.create().onNext(printValue));
    // Output: 2, 3...
}
```
### <a id="share"></a>Share
Share is a shorthand for [.publish().refCount()](#refcount).
```javascript
IObservable o := Observable.interval(1.0).share();
ISubscription s := o.subscribe(Subscriber.create().onNext(printValue));
// Output: 0, 1, 2, 3...
on wait(2.0) {
    ISubscription s2 := o.subscribe(Subscriber.create().onNext(printValue));
    // Output: 2, 3...
}
```
## <a id="subject"></a>Subject
Subjects are just like channels in EPL in that they are a multicast way to send messages to all subscribers. Usually any late subscribers miss the messages. There are a few different types of subject that have various different behaviours.
### <a id="subject-types"></a>Types
**Subject** - A normal subject, sends messages to all subscribers
**BehaviourSubject** - A subject that always has a current value and sends this to new subscribers.
**ReplaySubject** - Replays a certain number of missed values to new subscribers.
### <a id="subject-construction"></a>Constructing a Subject
Creating a Subject is an alternative way to start an Observable chain (See also: [Observable](#observable))
```javascript
ISubject s := Subject.create();
         s := BehaviourSubject.create("InitialValue");
         s := ReplaySubject.create(3);
```
### <a id="subject-sending"></a>Sending Data
**next(any value)** - Send the next value to be processed
```javascript
ISubject subject := Subject.create();

ISubscription s := s.subscribe(Subscriber.create().onNext(printValue));

subject.next(1);
// Output: 1
```
**complete()** - Close the pipe
```javascript
ISubject subject := Subject.create();

ISubscription s := s.subscribe(Subscriber.create().onNext(printValue).onComplete(printDone));

subject.next(1);
subject.complete();
// Output: 1, Done
```
**error(any error)** - Send an error and close the pipe
```javascript
ISubject subject := Subject.create();

ISubscription s := s.subscribe(Subscriber.create().onError(printError));

subject.error("An error occurred");
// Output: An error occurred
```
## <a id="debugging"></a>Debugging
### do
Do is a handy operator that allows you to inspect the values as they pass through a chain of observables. It is like a subscriber except that it is passive, only receiving messages when someone is subscribed further down the chain.
```javascript
IObservable o := Observable.interval(1.0);
ISubscription s := o.take(5);
                    .do(Subscriber.create()
                                  .onNext(printValue)
                                  .onError(printError)
                                  .onComplete(printComplete));
                     .map(multiplyBy10)
                     .subscribe(Subscriber.create()
                                          .onNext(printValue)
                                          .onError(printError)
                                          .onComplete(printComplete));
// Output from Do: 0, 1, 2, 3, 4, Done
// Output from Subscriber: 0, 10, 20, 30, 40, Done
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
sequence<action<action<IObserver> returns ISubscription> > returns
                                             action<IObserver> returns ISubscription> 
    tempTooHigh := [Pluck.create("temperature"), Filter.create(outsideThreshold)];
    
IObservable o := myObservableTemps
   .pipe(tempTooHigh);
```
### Option 3:  Create a custom pipe - Best
```javascript
event TempTooHigh {    
    static action create() returns action<action<IObserver> returns ISubscription>
                                             returns action<IObserver> returns ISubscription {
        return Pipe.create([
            Pluck.create("temperature"),
            Filter.create(outsideThreshold)
        ]);
    }
}
    
IObservable o := myObservableTemps
   .pipe([TempTooHigh.create()]);

// or

IObservable o := myObservableTemps
   .let(TempTooHigh.create());
```
## <a id="gotchas"></a>Gotchas
### <a id="gotcha-multiple-subscribers"></a>Multiple Subscribers
```javascript
IObservable sharedObs := Observable.interval(1.0);
ISubscription s1 := sharedObs.subscribe(Subscriber.create().onNext(printValue));
// Output: 0,1,2,3...
on wait(2.0) {    
    ISubscription s2 := sharedObs.subscribe(Subscriber.create().onNext(printValue));
    // Output: 0,1,2,3... What?
}
```
**Why?**
Each subscriber creates it's own chain through to the source. In this case that means that each subscriber get it's own interval.
**Solution**
Use [Share](#multicasting)
```javascript
IObservable sharedObs := Observable.interval(1.0).share();
ISubscription s1 := sharedObs.subscribe(Subscriber.create().onNext(printValue));
// Output: 0,1,2,3...
on wait(2.0) {    
    ISubscription s2 := sharedObs.subscribe(Subscriber.create().onNext(printValue));
    // Output: 2,3...
}
```
### <a id="gotcha-subscribe-on"></a>Publish/Share and SubscribeOn
```javascript
IObservable sharedObs := Observable.interval(1.0).share();

ISubscription s1 := sharedObs.subscribe(Subscriber.create().onNext(printValue));    
ISubscription s2 := sharedObs.subscribeOnNew(Subscriber.create().onNext(printValue));
// Output on "Main Context": 0,1,2,3...
// Output on "New Context": Nothing.... What?!       
```
**Why?**
Publish and Share both store information about their current subscribers and upstream connections. When the entire chain is moved onto another context this information is copied and the operators no longer function correctly.
***Solution*** - `.decouple()`
```javascript
IObservable sharedObs := Observable.interval(1.0)
                                   .share();

ISubscription s1 := sharedObs.subscribe(Subscriber.create().onNext(printValue));
ISubscription s2 := sharedObs.decouple() // Note: observeOn may be a better solution
                           .subscribeOnNew(Subscriber.create().onNext(printValue));
// Output on "Main Context": 0,1,2,3...
// Output on "New Context": 0,1,2,3...
```
This helps by 'decoupling' the upstream and the downstream. When subscribeOn is called only the downstream is copied. This means that only part of the chain is running on a separate context. A better solution might be to use ObserveOn instead of subscribeOn.
## <a id="other"></a>Help and Other Resources
**[ReactiveX Website](http://reactivex.io/)** - A Great place to get info about the background to the framework.
**[Decision Tree Of Observables](http://reactivex.io/documentation/operators.html#tree)** - Don't know which operator to use? Follow this
**[RxMarbles](http://rxmarbles.com/)** - An interactive tool to play with observable operators