# <a name="replaysubject"></a>com.industry.rx_epl.ReplaySubject [<>](/src/rx/objects/ReplaySubject.mon)

A subject that allows values to be sent to all subscribers. Late subscribers will receive some or all of the messages that they have missed.

## Methods

* [Create](#create)

<a name="create" href="#create">#</a> .**create**(*`count:` integer*) returns [ISubject](../interfaces/ISubject.md#isubject) [<>](/src/rx/objects/ReplaySubject.mon  "Source")

Creates a new [ReplaySubject](#subject). It will store the last `count` values and replay them to any new subscribers.

```javascript
ISubject s := ReplaySubject.create(2);

ISubscription sub1 := s.subscribe(...);
s.next("Value1"); // Output (from sub1): "Value1"
s.next("Value2"); // Output (from sub1): "Value2"
s.next("Value3"); // Output (from sub1): "Value3"

// Late subscription
ISubscription sub2 := s.subscribe(...); // Output (from sub2): "Value2", "Value3"

s.next("Value4"); // Output (from sub1 and sub2): "Value4"

s.complete();
```
