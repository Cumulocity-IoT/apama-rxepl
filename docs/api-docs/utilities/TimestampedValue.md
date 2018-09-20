# <a name="timestampedvalue"></a>com.industry.rx_epl.TimestampedValue [<>](/src/rx/objects/TimestampedValue.mon)

Contains both the timestamp (`currentTime` when the value was timestamped) and the current value. Returned by calls to [.timestamp()](../interfaces/IObservable.md#timestamp).

## Fields

<a name="timestamp" href="#timestamp">#</a> float **timestamp** [<>](/src/rx/objects/TimestampedValue.mon  "Source")

The timestamp (seconds since the epoch).

Note: By default all calls to `currentTime` return 100 millisecond precision.

<a name="value" href="#value">#</a> any **value** [<>](/src/rx/objects/TimestampedValue.mon  "Source")

The value.
