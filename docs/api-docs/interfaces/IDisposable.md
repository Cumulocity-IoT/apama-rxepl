# <a name="idisposable"></a>com.industry.rx_epl.IDisposable[<>](/src/rx/interfaces/IDisposable.mon)
Allows a resource to be disposed after use is finished.

## Methods
* [Dispose](#dispose)

<a name="dispose" href="#dispose">#</a> .**dispose**() [<>](/src/rx/interfaces/IDisposable.mon  "Source")

Dispose of an unused resource.

```javascript
IDisposable d := Observable.interval(1.0)
	.toChannel("Abc");

d.dispose(); // Terminate the toChannel and the observable.
```
