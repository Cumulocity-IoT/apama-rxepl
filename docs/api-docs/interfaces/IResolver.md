# <a name="iresolver"></a>com.industry.rx_epl.IResolver[<>](/src/rx/interfaces/IResolver.mon)

Used by [Observable.create(...)](../constructors/Observable.md#create) as the utility to emit values, error, or completion from an observable source.

## Methods
* [Next](#next)
* [Error](#error)
* [Complete](#complete)
* [OnUnsubscribe](#onunsubscribe)

<a name="next" href="#next">#</a> .**next**(*`value:` any*) [<>](/src/rx/objects/IResolver.mon  "Source")

Send the next value to the subscriber.

Note: This action is automatically disconnected on unsubscription. 

```javascript
action fromEventListener(IResolver r) {
	r.next("value1");
	r.next("value2");
	r.complete();
}

ISubscription s := Observable.create(fromEventListener)
	.subscribe(...);
```

<a name="error" href="#error">#</a> .**error**(*`error:` any*) [<>](/src/rx/objects/IResolver.mon  "Source")

Send an error to the subscriber (Usually `com.apama.exceptions.Exception(...)`). Once an error has been sent the observable is terminated.

Note: This action is automatically disconnected on unsubscription. 

```javascript
action fromEventListener(IResolver r) {
	r.error(com.apama.exceptions.Exception("Oh no!", "RuntimeException"));
}

ISubscription s := Observable.create(fromEventListener)
	.subscribe(...);
```

<a name="complete" href="#complete">#</a> .**complete**() [<>](/src/rx/objects/IResolver.mon  "Source")

Send a complete notification to the subscriber. Once complete has been sent the observable is terminated.

Note: This action is automatically disconnected on unsubscription. 

```javascript
action fromEventListener(IResolver r) {
	r.complete();
}

ISubscription s := Observable.create(fromEventListener)
	.subscribe(...);
```

<a name="onunsubscribe" href="#onunsubscribe">#</a> .**onUnsubscribe**(*`callback:` action<>*) [<>](/src/rx/objects/IResolver.mon  "Source")

Add a listener for the termination of the subscription.

```javascript
action fromEventListener(IResolver r) {
	listener values := on all MyEvent() as e {
		r.next(e);
	}
	
	r.onUnsubscribe(values.quit); // This is important, otherwise we leak a listener
}

ISubscription s := Observable.create(fromEventListener)
	.subscribe(...);
```
