# <a name="subscriber"></a>com.industry.rx_epl.Subscriber [<>](/src/rx/objects/Subscriber.mon)

A [Subscriber](#subscriber) contains the callbacks used when a subscription receives a value/error/complete. It is passed to the [.subscribe(...)](../interfaces/IObservable.md#subscribe) method.

Note: Subscribers should not be reused for multiple subscriptions.

## Constructors

* [Create](#create)

<a name="create" href="#create">#</a> *static* .**create**() returns [Subscriber](#subscriber) [<>](/src/rx/objects/Subscriber.mon  "Source")

Creates a new [Subscriber](#subscriber).

```javascript
Observable.fromValues([1,2,3])
	.subscribe(Subscriber.create().onNext(...).onError(...).onComplete(...));
```

## Methods

* [OnNext](#onnext)
* [OnComplete](#oncomplete)
* [OnError](#onerror)

<a name="onnext" href="#onnext">#</a> .**onNext**(*`callback:` action<[T](/docs/api-docs/README.md#wildcard-class-notation)>*) returns [Subscriber](#subscriber) [<>](/src/rx/objects/Subscriber.mon  "Source")

Register a callback to be called whenever the subscription receives a value.

```javascript
action logInteger(integer x) {
	log x.toString();
}

Observable.fromValues([1,2,3])
	.subscribe(Subscriber.create().onNext(logInteger));
```

<a name="oncomplete" href="#oncomplete">#</a> .**onComplete**(*`callback:` action<>*) returns [Subscriber](#subscriber) [<>](/src/rx/objects/Subscriber.mon  "Source")

Register a callback to be called when the subscription completes.

```javascript
action logDone() {
	log "Done";
}

Observable.fromValues([1,2,3])
	.subscribe(Subscriber.create().onComplete(logDone));
```

<a name="onerror" href="#onerror">#</a> .**onError**(*`callback:` action<[E](/docs/api-docs/README.md#wildcard-class-notation)>*) returns [Subscriber](#subscriber) [<>](/src/rx/objects/Subscriber.mon  "Source")

Register a callback to be called when the subscription receives an error. The error can be of any type but is usually `com.apama.exceptions.Exception`.

Note: The subscription is terminated when an error is received.

Note: If no error handler is registered then the default handler rethrows the exception.

```javascript
action logError(com.apama.exceptions.Exception e) {
	log e.getMessage();
}

Observable.error()
	.subscribe(Subscriber.create().onError(logError));
```

