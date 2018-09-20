# <a name="disposablestream"></a>com.industry.rx_epl.DisposableStream [<>](/src/rx/objects/DisposableStream.mon)

Wrapper for a stream to allow the stream and the observable to be terminated together. Returned by calls to [.toStream(...)](../interfaces/IObservable.md#tostream).

## Methods

* [GetStream](#getstream)
* [Dispose](#dispose)

<a name="getstream" href="#getstream">#</a> .**getStream**() returns stream\<any> [<>](/src/rx/objects/DisposableStream.mon  "Source")

Access the stream\<any>.

Note: [.dispose()](#dispose) should be used rather than stream.quit().

```javascript
DisposableStream ds := Observable.interval(1.0)
	.toStream();

stream<any> strm := ds.getStream();

stream<integer> intStream := from v in strm select <integer> v;
```

<a name="dispose" href="#dispose">#</a> .**dispose**() [<>](/src/rx/objects/DisposableStream.mon  "Source")

Dispose of a stream and the observable source.

Note: Calls stream.quit() which will terminate any stream listeners.

```javascript
DisposableStream ds:= Observable.interval(1.0)
	.toStream();

ds.dispose(); // Terminate the observable and the stream.
```
