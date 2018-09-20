# <a name="wrappedany"></a>com.industry.rx_epl.WrappedAny [<>](/src/rx/utils/WrappedAny.mon)

A wrapper for primitive (`integer`, `float`, `decimal`, `boolean`, `string`) or non-event (`sequence`, `dictionary`...) types to allow them to be sent to a channel. Useful when sending values to [Observable.fromChannel(...)](../constructors/Observable.md#fromchannel) or receiving values from [.toChannel(...)](../interfaces/IObservable.md#toChannel).

## Fields

<a name="value" href="#value">#</a> any **value** [<>](/src/rx/utils/WrappedAny.mon  "Source")

The value.
