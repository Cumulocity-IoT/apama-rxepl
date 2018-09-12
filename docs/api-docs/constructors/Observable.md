# <a name="observable"></a>com.industry.rx_epl.Observable [<>](/src/rx/objects/Observable.mon)
The main class of RxEPL. This event implements the [IObservable](../interfaces/IObservable#iobservable-) interface and contains all of the various observable construction methods (which all return [IObservable](../interfaces/IObservable#iobservable-)).

## Methods

All of the public API for this event is static and as such this event should never be manually constructed. This is categorised list of the methods:

* Construction
	* Create
	* Just
	* FromValues
	* Interval
	* Range
	* Repeat
	* Timer
	* FromIterator
	* FromStream
	* FromChannel
	* Start
	* Empty/Never/Error
	* ObserveFromChannel
* Combinatory Operations
	* Merge
	* WithLatestFrom/WithLatestFromToSequence
	* CombineLatest/CombineLatestToSequence
	* Zip/ZipToSequence
	* Concat
	* SequenceEqual
	* Amb
