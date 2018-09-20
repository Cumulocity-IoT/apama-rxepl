# <a name="isubscription"></a>com.industry.rx_epl.ISubscription [<>](/src/rx/interfaces/ISubscription.mon)
The interface returned by calls to [IObservable.subscribe(...)](IObservable.md#subscribe). Contains methods to unsubscribe and add listeners.

## Methods
- [OnUnsubscribe](#onunsubscribe)
- [Unsubscribe](#unsubscribe)
- [Subscribed](#subscribed)

<a name="onunsubscribe" href="#onunsubscribe">#</a> .**onUnsubscribe**(*`callback:` action<>*) [<>](/src/rx/objects/Subscription.mon  "Source")

Add a listener for the termination of the subscription (by completing, erroring, or being manually unsubscribed).

```javascript
action myCallback() {
	log "Finished Processing";
}

ISubscription s := Observable.timer("Value", 1.0)
	.subscribe(...);

s.onUnsubscribe(myCallback);
// Logs (After 1 second): "Finished Processing"
```

<a name="unsubscribe" href="#unsubscribe">#</a> .**unsubscribe**() [<>](/src/rx/objects/Subscription.mon  "Source")

Terminate this observable subscription.

```javascript
ISubscription s := Observable.timer("Value", 1.0)
	.subscribe(...);

s.unsubscribe();
// Won't do anything when the timer fires because we unsubscribed
```

<a name="subscribed" href="#subscribed">#</a> .**subscribed**() returns boolean [<>](/src/rx/objects/Subscription.mon  "Source")

Check whether a subscription is active.

```javascript
ISubscription s := Observable.timer("Value", 1.0)
	.subscribe(...);

if s.subscribed() {
	log "We're still connected";
}
```
