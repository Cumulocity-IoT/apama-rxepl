# <a name="loggingsubscriber"></a>com.industry.rx_epl.LoggingSubscriber [<>](/src/rx/objects/LoggingSubscriber.mon)

A specialised instance of a [Subscriber](../Subscriber.md#subscriber) which logs all values and completion, error, and unsubscription.

Note: Subscribers should not be reused for multiple subscriptions.

## Constructors

* [Create](#create)

<a name="create" href="#create">#</a> *static* .**create**(`identifier:` string) returns [Subscriber](../Subscriber.md#subscriber) [<>](/src/rx/objects/LoggingSubscriber.mon  "Source")

Creates a new [LoggingSubscriber](#loggingsubscriber). The `identifier` is added to all messages produced.

```javascript
Observable.fromValues([1,2,3])
	.subscribe(LoggingSubscriber.create("Output"));

// Output in the log file:
// # Output: Received value: 1
// # Output: Received value: 2
// # Output: Received value: 3
// # Output: Completed
// # Output: Unsubscribed
```
