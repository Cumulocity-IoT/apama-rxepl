# <a name="subject"></a>com.industry.rx_epl.Subject [<>](/src/rx/objects/Subject.mon)

A simple subject that allows values to be sent to all subscribers.

## Constructors

* [Create](#create)

<a name="create" href="#create">#</a> *static* .**create**() returns [ISubject](../interfaces/ISubject.md#isubject) [<>](/src/rx/objects/Subject.mon  "Source")

Creates a new [Subject](#subject).

```javascript
ISubject s := Subject.create();

ISubscription sub1 := s.subscribe(...);
s.next("Value1"); // Output (from sub1): "Value1"

ISubscription sub2 := s.subscribe(...);
s.next("Value2"); // Output (from sub1 and sub2): "Value2"

sub1.dispose();
s.next("Value3"); // Output (from sub2): "Value3"

s.complete(); // sub2 terminates (calling it's onComplete)
```
