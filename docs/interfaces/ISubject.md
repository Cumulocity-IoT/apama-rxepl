# <a name="isubject"></a>com.industry.rx_epl.ISubject [<>](/src/rx/interfaces/ISubject.mon)

ISubject is designed to be a subclass of [IObservable](./IObservable#iobservable), as such it has all of the methods on an [IObservable](./IObservable#iobservable). It also contains methods to allow values to be injected into the IObservable:

## Methods

* [Next](#next)
* [Error](#error)
* [Complete](#complete)
* [AsIObservable](#asiobservable)

<a name="next" href="#next">#</a> .**next**(*`value:` any*) [<>](/src/rx/interfaces/ISubject.mon  "Source")

Sends a value to all subscribers.

```javascript
ISubject s := Subject.create();

ISubscription sub := s.subscribe(...); // Receives "abc" when .next(...) is called

s.next("abc");
```

<a name="error" href="#error">#</a> .**error**(*`error:` any*) [<>](/src/rx/interfaces/ISubject.mon  "Source")

Sends an error to all subscribers. Errors will terminate the subject.

```javascript
ISubject s := Subject.create();

ISubscription sub := s.subscribe(...); // Receives an error and terminates the subscription

s.error(com.apama.exceptions.Exception("Oh no!", "RuntimeException"));
```

<a name="complete" href="#complete">#</a> .**complete**() [<>](/src/rx/interfaces/ISubject.mon  "Source")

Sends a complete to all subscribers. Complete will terminate the subject.

```javascript
ISubject s := Subject.create();

ISubscription sub := s.subscribe(...); // Receives complete and terminates the subscription

s.complete();
```

<a name="asiobservable" href="#asiobservable">#</a> .**asIObservable**() returns [IObservable](./IObservable.md#iobservable)\<[T](/docs/README.md#wildcard-class-notation)> [<>](/src/rx/interfaces/ISubject.mon  "Source") 

Converts a subject to an IObservable.

```javascript
ISubject s := Subject.create();

IObservable o := s.asIObservable();
```
