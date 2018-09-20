# <a name="behaviorsubject"></a>com.industry.rx_epl.BehaviorSubject [<>](/src/rx/objects/BehaviorSubject.mon)

A subject that starts with an initial value and replays the latest value to new subscribers.

## Methods

* [Create](#create)

<a name="create" href="#create">#</a> .**create**(*`initialValue:` any*) returns [ISubject](../interfaces/ISubject.md#isubject) [<>](/src/rx/objects/BehaviorSubject.mon  "Source")

Creates a new [BehaviorSubject](#behaviorsubject). Starting with the `initialValue`.

```javascript
ISubject s := BehaviorSubject.create("Initial Value");

ISubscription sub1 := s.subscribe(...); // Output (from sub1): "Initial Value"

s.next("Value2"); // Output (from sub1): "Value2"

ISubscription sub2 := s.subscribe(...); // Output (from sub2): "Value2"

s.next("Value3"); // Output (from sub1 and sub2): "Value3"

s.complete();
```
