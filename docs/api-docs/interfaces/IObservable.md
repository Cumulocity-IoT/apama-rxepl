
# IObservable [<>](/src/rx/interfaces/IObservable.mon)

IObservable is the interface returned by most RxEPL operators. 
Unless otherwise stated all methods on this interface return an IObservable, this provides [Method Chaining](https://en.wikipedia.org/wiki/Method_chaining).

## Methods
Thes are broken up into:
* [Transforms](#transforms)
	* [Map](#map)
	* [FlatMap](#flatmap)
	* [Pluck](#pluck)
	* [Scan](#scan)/[ScanWithInitial](#scanwithinitial)
	* [GroupBy](#groupby)/[GroupByField](#groupbyfield)
	* [GroupByWindow](#groupbywindow)/[WindowTime](#windowtime)/[WindowCount](#windowcount)/[WindowTimeOrCount](#windowtimeorcount)
	* [Buffer](#buffer)/[BufferTime](#buffertime)/[BufferCount](#buffercount)/[BufferCountSkip](#buffercountskip)/[BufferTimeOrCount](#buffertimeorcount)/[Pairwise](#pairwise)
	* [Sort](#sort)/[SortAsc](#sortasc)/[SortDesc](#sortdesc)
	* [ToSortedList](#tosortedlist)/[ToSortedListAsc](#tosortedlistasc)/[ToSortedListDesc](tosorteddesclist)
* [Filters](#filters)
	* [Filter](#filter)
	* [Distinct](#distinct)/[DistinctUntilChanged](#distinctuntilchanged)/[DistinctBy](#distinctby)/[DistinctByUntilChanged](#distinctbyuntilchanged)/[DistinctByField](#distinctbyfield)/[DistinctByFieldUntilChanged](#distinctbyfielduntilchanged)
	* [Take](#take)/[First](#first)/[TakeLast](#takelast)/[Last](#last)
	* [Skip](#skip)/[SkipLast](#skiplast)
	* [TakeUntil](#takeuntil)/[TakeWhile](#takewhile)
	* [SkipUntil](#skipuntil)/[SkipWhile](#skipwhile)
	* Debounce/ThrottleFirst/ThrottleLast
	* Sample/SampleTime/SampleCount/SampleTimeOrCount
	* ElementAt
* [Combiners](#combiners)
	* Merge/MergeAll
	* WithLatestFrom/WithLatestFromToSequence
	* CombineLatest/CombineLatestToSequence
	* Zip/ZipToSequence
	* Concat/StartWith
	* SwitchMap/SwitchOnNext
* [Error Handling](#error-handling)
	* [CatchError](#catcherror)
	* [Retry](#retry)
* [Utils](#utils)
	* Do
	* Delay/Async
	* ObserveOn/ObserveOnNew
	* Subscribe/SubscribeOn/SubscribeOnNew
	* ToChannel/ToStream
	* Timestamp/UpdateTimestamp
	* TimeInterval
	* Let/Pipe/PipeOn/PipeOnNew
	* ComplexPipe/ComplexPipeOn/ComplexPipeOnNew
	* Decouple
	* GetSync/GetSyncOr
	* Repeat
	* Publish/PublishReplay
	* Connect/RefCount
	* Share/ShareReplay
	* ObserveToChannel
	* IgnoreElements
* [Conditional](#conditional)
	* Contains/Every
	* SequenceEqual
	* Amb
	* DefaultIfEmpty
* [Math and Aggregation](#math-and-aggregation)
	* Reduce/ReduceWithInitial
	* Count
	* Sum/SumInteger/SumFloat/SumDecimal/ConcatString
	* Max/MaxInteger/MaxFloat/MaxDecimal
	* Min/MinInteger/MinFloat/MinDecimal
	* Average/AverageDecimal

### Transforms
Actions that modify values coming from the source.

<a name="map" href="#map">#</a> .**map**(*action<`value:` [T1](/docs#wild-card-notation)> returns [T2](/docs#wild-card-notation)*) returns [IObservable](#iobservable-)<[T2](/docs#wild-card-notation)> [<>](/src/rx/operators/Map.mon  "Source")

Apply a function to each `value` and pass on the result.
```javascript
action multiplyBy10(integer value) returns integer {
	return value * 10;
}

Observable.fromValues([1,2,3])
	.map(multiplyBy10)
	...
	
// Output: 10, 20, 30
```
See also [FlatMap](#flatmap).

<a name="flatmap" href="#flatmap">#</a> .**flatMap**(*action<`value:` [T1](/docs#wild-card-notation)> returns (sequence<[T2](/docs#wild-card-notation)> | [IObservable](#iobservable-)<[T2](/docs#wild-card-notation)> | [ISubject](ISubject.md#isubject)<[T2](/docs#wild-card-notation)>)*) returns [IObservable](#iobservable-)<[T2](/docs#wild-card-notation)> [<>](/src/rx/operators/FlatMap.mon  "Source")

Apply a mapping to each `value` that results in multiple values (or an Observable containing 1 or more values) and merge each item in the result into the output.
```javascript
action valueAndPlus1(integer value) returns sequence<integer> {
	return [value, value + 1];
}

Observable.fromValues([1,3,5])
	.flatMap(valueAndPlus1)
	...

// Output: 1, 2, 3, 4, 5, 6
```

See also: [Map](#map).

<a name="pluck" href="#pluck">#</a> .**pluck**(*`fieldName:` any*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/Pluck.mon  "Source")

Select a particular field from the incoming value.

Note: The `fieldName` can be of any type (Eg. an integer for [IObservable](#iobservable-)\<sequence> or the key type for an [IObservable](#iobservable-)\<dictionary>)
```javascript
event E {
	integer value;
}

Observable.fromValues([E(1), E(2), E(3), E(4)])
	.pluck("value")
	...

// Output: 1,2,3,4
```

<a name="scan" href="#scan">#</a> .**scan**(*action<`aggregate:` [T2](/docs#wild-card-notation), `value:` [T1](/docs#wild-card-notation)> returns [T2](/docs#wild-card-notation)*) returns [IObservable](#iobservable-)<[T2](/docs#wild-card-notation)> [<>](/src/rx/operators/Scan.mon  "Source")

Aggregate the data and emit the aggregated value for every incoming event.

Note: The first value is emitted without aggregation
```javascript
action sum(integer currentSum, integer value) returns integer {
	return currentSum + value;
}

Observable.fromValues([1,2,3])
	.scan(sum)
	...

// Output: 1, 3, 6
```
See also: [ScanWithInitial](#scanwithinitial), [Reduce](#reduce)

<a name="scanwithinitial" href="#scanwithinitial">#</a> .**scanWithInitial**(*action<`aggregate:` [T2](/docs#wild-card-notation), `value:` [T1](/docs#wild-card-notation)> returns [T2](/docs#wild-card-notation), `initialValue:` [T2](/docs#wild-card-notation)*) returns [IObservable](#iobservable-)<[T2](/docs#wild-card-notation)> [<>](/src/rx/operators/Scan.mon  "Source")

Aggregate the data and emit the aggregated value for every incoming event. The initial value for the aggregation is supplied.
```javascript
action sum(integer currentSum, integer value) returns integer {
	return currentSum + value;
}

Observable.fromValues([1,2,3])
	.scanWithInitial(sum, 5)
	...

// Output: 6, 8, 11
```
See also: [Scan](#scan), [ReduceWithInitial](#reducewithinitial)

<a name="groupby" href="#groupby">#</a> .**groupBy**(*action<`value:` [T1](/docs#wild-card-notation)> returns [T2](/docs#wild-card-notation)*) returns [IObservable](#iobservable-)<[IObservable](#iobservable-)<[T1](/docs#wild-card-notation)>> [<>](/src/rx/operators/GroupBy.mon  "Source")

Group the data into separate observables based on a calculated group identifier. These observables are sent on the resulting [IObservable](#iobservable-). The provided action takes a value and returns a group identifier.
```javascript
event Fruit {
	string type;
	integer value;
}

action groupId(Fruit fruit) returns string {
	return fruit.type;
}

action sumValuesInGroup(IObservable group) returns IObservable {
	return group
		.reduceWithInitial(Lambda.function2("groupResult, fruit => [fruit.type, groupResult[1] + fruit.value]"), ["", 0]);
}

Observable.fromValues([Fruit("apple", 1), Fruit("banana", 2), Fruit("apple", 3)])
	.groupBy(groupId)
	.flatMap(sumValuesInGroup)
	...

// Output: ["banana", 2], ["apple", 4]
```
See also: [GroupByField](#groupbyfield), [GroupByWindow](#groupbywindow)

<a name="groupbyfield" href="#groupbyfield">#</a> .**groupByField**(*`fieldName:` [any](/docs#wild-card-notation)*) returns [IObservable](#iobservable-)<[IObservable](#iobservable-)\<[T](/docs#wild-card-notation)>> [<>](/src/rx/operators/GroupBy.mon  "Source")

Group the data into separate observables based on a key field. These observables are sent on the resulting [IObservable](#iobservable-).

Note: The `fieldName` can be of any type (Eg. an integer for [IObservable](#iobservable-)\<sequence> or the key type for an [IObservable](#iobservable-)\<dictionary>)

```javascript
event Fruit {
	string type;
	integer value;
}

action sumValuesInGroup(IObservable group) returns IObservable {
	return group
		.reduceWithInitial(Lambda.function2("groupResult, fruit => [fruit.type, groupResult[1] + fruit.value]"), ["", 0]);
}

Observable.fromValues([Fruit("apple", 1), Fruit("banana", 2), Fruit("apple", 3)])
	.groupByField("type")
	.flatMap(sumValuesInGroup)
	...

// Output: ["banana", 2], ["apple", 4]
```
See also: [GroupBy](#groupby), [GroupByWindow](#groupbywindow)

<a name="groupbywindow" href="#groupbywindow">#</a> .**groupByWindow**(*`trigger:` [IObservable](#iobservable-)*) returns [IObservable](#iobservable-)<[IObservable](#iobservable-)\<[T](/docs#wild-card-notation)>> [<>](/src/rx/operators/Window.mon  "Source")

Partition each value into the current observable window. The observable windows are sent on the resulting [IObservable](#iobservable-). The provided `trigger` determines when a new window is created.

Note: The current window is completed when a new window is created.

```javascript
action source(IResolver r) {
	listener l := on all wait(0.25) {
		r.next(1);
	}
	r.onUnsubscribe(l.quit);
}

action sumValuesInWindow(IObservable group) returns IObservable {
	return group.sum();
}

Observable.create(source)
	.groupByWindow(Observable.interval(1.0))
	.flatMap(sumValuesInWindow)
	...

// Output: 3, 4, 4...
```
See also: [Buffer](#buffer), [GroupBy](#groupby)

<a name="windowtime" href="#windowtime">#</a> .**windowTime**(*`seconds:` float*) returns [IObservable](#iobservable-)<[IObservable](#iobservable-)\<[T](/docs#wild-card-notation)>> [<>](/src/rx/operators/Window.mon  "Source")

Partition each value into the current observable window. The observable windows are sent on the resulting [IObservable](#iobservable-). A new window is created every t seconds (starting when the subscription begins).

Note: The current window is completed when a new window is created.

```javascript
action source(IResolver r) {
	listener l := on all wait(0.25) {
		r.next(1);
	}
	r.onUnsubscribe(l.quit);
}

action sumValuesInWindow(IObservable group) returns IObservable {
	return group.sum();
}

Observable.create(source)
	.windowTime(1.0)
	.flatMap(sumValuesInWindow)
	...

// Output: 3, 4, 4...
```
See also: [BufferTime](#buffertime), [GroupBy](#groupby)

<a name="windowcount" href="#windowcount">#</a> .**windowCount**(*`count:` integer*) returns [IObservable](#iobservable-)<[IObservable](#iobservable-)\<[T](/docs#wild-card-notation)>> [<>](/src/rx/operators/Window.mon  "Source")

Partition each value into the current observable window. The observable windows are sent on the resulting [IObservable](#iobservable-). A new window is created after every n values.

Note: The current window is completed when a new window is created.

```javascript
action sumValuesInWindow(IObservable group) returns IObservable {
	return group.sum();
}

Observable.fromValues([1,2,3,4,5,6])
	.windowCount(2)
	.flatMap(sumValuesInWindow)
	...

// Output: 3, 7, 11
```
See also: [BufferCount](#buffercount), [GroupBy](#groupby)

<a name="windowtimeorcount" href="#windowtimeorcount">#</a> .**windowTimeOrCount**(*`seconds:` float, `count:` integer*) returns [IObservable](#iobservable-)<[IObservable](#iobservable-)\<[T](/docs#wild-card-notation)>> [<>](/src/rx/operators/Window.mon  "Source")

Partition each value into the current observable window. The observable windows are sent on the resulting [IObservable](#iobservable-). A new window is created after every t seconds or n values (whichever comes first).

Note: The current window is completed when a new window is created.

See also: [BufferTimeOrCount](#buffertimeorcount), [GroupBy](#groupby)

<a name="buffer" href="#buffer">#</a> .**buffer**(*`trigger:` [IObservable](#iobservable-)*) returns [IObservable](#iobservable-)<sequence\<any>> [<>](/src/rx/operators/Buffer.mon  "Source")

Store each value in the current bucket, emitting the bucket (as a sequence\<any>) when the trigger fires.

Note: The final bucket will be emitted on completion of the source. Unsubscribing will not trigger emission of the the current bucket.
```javascript
Observable.interval(0.25) // Emits an incrementing integer every 250 millis
	.buffer(Observable.interval(1.0))
	...

// Output: [0,1,2,3], [4,5,6,7], [8,9,10,11]...
```
See also: [GroupByWindow](#groupbywindow), [GroupBy](#groupby)

<a name="buffertime" href="#buffertime">#</a> .**bufferTime**(*`seconds:` float*) returns [IObservable](#iobservable-)<sequence\<any>> [<>](/src/rx/operators/BufferTime.mon  "Source")

Store each value in the current bucket, emitting the bucket (as a sequence\<any>) every t seconds.

Note: The final bucket will be emitted on completion of the source. Unsubscribing will not trigger emission of the the current bucket.
```javascript
Observable.interval(0.25) // Emits an incrementing integer every 250 millis
	.bufferTime(1.0)
	...

// Output: [0,1,2,3], [4,5,6,7], [8,9,10,11]...
```
See also: [WindowTime](#windowtime), [GroupBy](#groupby)

<a name="buffercount" href="#buffercount">#</a> .**bufferCount**(*`count:` integer*) returns [IObservable](#iobservable-)<sequence\<any>> [<>](/src/rx/operators/Buffer.mon  "Source")

Store each value in the current bucket, emitting the bucket (as a sequence\<any>) every n values.

Note: The final bucket will be emitted on completion of the source. Unsubscribing will not trigger emission of the the current bucket.
```javascript
Observable.fromValues([1,2,3,4,5,6])
	.bufferCount(2)
	...

// Output: [1,2], [3,4], [5,6]
```
See also: [WindowCount](#windowcount), [BufferCountSkip](#buffercountskip), [Pairwise](#pairwise)

<a name="buffercountskip" href="#buffercountskip">#</a> .**bufferCountSkip**(*`count:` integer, `skip:` integer*) returns [IObservable](#iobservable-)<sequence\<any>> [<>](/src/rx/operators/Buffer.mon  "Source")

Store each value in the current bucket, emitting the bucket (as a sequence\<any>) every `count` values. The bucket 'slides' such that, after filling for the first time, it emits every `skip` values with the last `count` items.

Note: The final bucket and all partial buckets (caused by the sliding) will be emitted on completion. Unsubscribing will not trigger emission of the the current bucket.

Note 2: The skip value can be greater than the count, this will cause a gap between buckets.

```javascript
Observable.fromValues([1,2,3,4,5,6])
	.bufferCountSkip(3,1)
	...

// Output: [1,2,3], [2,3,4], [3,4,5], [4,5,6], [5,6], [6]
```
See also: [BufferCount](#buffercount), [Pairwise](#pairwise)

<a name="buffertimeorcount" href="#buffertimeorcount">#</a> .**bufferTimeOrCount**(*`seconds:` float, `count:` integer*) returns [IObservable](#iobservable-)<sequence\<any>> [<>](/src/rx/operators/Buffer.mon  "Source")

Store each value in the current bucket, emitting the bucket (as a sequence\<any>) every `count` values or when the time `seconds` has elapsed (Whichever comes first).

Note: The final bucket will be emitted on completion of the source. Unsubscribing will not trigger emission of the the current bucket.

See also: [BufferCount](#buffercount), [BufferCountSkip](#buffercountskip)

<a name="pairwise" href="#pairwise">#</a> .**pairwise**() returns [IObservable](#iobservable-)<sequence\<any>> [<>](/src/rx/operators/Buffer.mon  "Source")

Emit every value and the previous value in a sequence\<any>.

Note: If only 1 value is received then no values are emitted.

```javascript
Observable.fromValues([1,2,3,4,5,6])
	.pairwise()
	...

// Output: [1,2], [2,3], [3,4], [4,5], [5,6]
```

See also: [BufferCount](#buffercount), [BufferCountSkip](#buffercountskip)

<a name="sort" href="#sort">#</a> .**sort**(*`comparator:` action<`left:` [T](/docs#wild-card-notation), `right:` [T](/docs#wild-card-notation)> returns number*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/ToSortedList.mon  "Source")

Sort the values by a comparator. The comparator takes 2 values from the observable and should produce a number to indicate which one is larger. 

A positive number indicates that the `right` value should be later in the output, whereas a negative number indicates the `left` value. 

Note: Uses the heapsort algorithm - there's no guaranteed ordering for equal values.
```javascript
action comparator(integer left, integer right) returns integer {
	return right - left;
}

Observable.fromValues([4,1,3,2])
	.sort(comparator)
	...

// Output: 1,2,3,4
```

<a name="sortasc" href="#sortasc">#</a> .**sortAsc**() returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/ToSortedList.mon  "Source")

Sort the values by the standard `>` or `<` comparator. Numbers with different types will be coerced to to same type before comparison.

Note: Uses the heapsort algorithm - there's no guaranteed ordering for equal values
```javascript
Observable.fromValues([4,1,3,2])
	.sortAsc()
	...

// Output: 1,2,3,4
```

<a name="sortdesc" href="#sortdesc">#</a> .**sortDesc**() returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/ToSortedList.mon  "Source")

Sort the values by the standard `>` or `<` comparator. Numbers with different types will be coerced to to same type before comparison.

Note: Uses the heapsort algorithm - there's no guaranteed ordering for equal values
```javascript
Observable.fromValues([4,1,3,2])
	.sortDesc()
	...

// Output: 4,3,2,1
```
<a name="tosortedlist" href="#tosortedlist">#</a> .**toSortedList**(*`comparator:` action<`left:` [T](/docs#wild-card-notation), `right:` [T](/docs#wild-card-notation)> returns number*) returns [IObservable](#iobservable-)<sequence<[T](/docs#wild-card-notation)>> [<>](/src/rx/operators/ToSortedList.mon  "Source")

Sort the values by a comparator. The comparator takes 2 values from the observable and should produce a number to indicate which one is larger. The sorted values are output as a sequence\<any>.

A positive number indicates that the `right` value should be later in the output, whereas a negative number indicates the `left` value. 

Note: Uses the heapsort algorithm - there's no guaranteed ordering for equal values.
```javascript
action comparator(integer left, integer right) returns integer {
	return right - left;
}

Observable.fromValues([4,1,3,2])
	.toSortedList(comparator)
	...

// Output: [1,2,3,4]
```

<a name="tosortedlistasc" href="#tosortedlistasc">#</a> .**toSortedListAsc**() returns [IObservable](#iobservable-)<sequence<[T](/docs#wild-card-notation)>> [<>](/src/rx/operators/ToSortedList.mon  "Source")

Sort the values by the standard `>` or `<` comparator. Numbers with different types will be coerced to to same type before comparison. The sorted values are output as a sequence\<any>.

Note: Uses the heapsort algorithm - there's no guaranteed ordering for equal values
```javascript
Observable.fromValues([4,1,3,2])
	.toSortedListAsc()
	...

// Output: [1,2,3,4]
```
<a name="tosortedlistdesc" href="#tosortedlistdesc">#</a> .**toSortedListDesc**() returns [IObservable](#iobservable-)<sequence<[T](/docs#wild-card-notation)>> [<>](/src/rx/operators/ToSortedList.mon  "Source")

Sort the values by the standard `>` or `<` comparator. Numbers with different types will be coerced to to same type before comparison. The sorted values are output as a sequence\<any>.

Note: Uses the heapsort algorithm - there's no guaranteed ordering for equal values
```javascript
Observable.fromValues([4,1,3,2])
	.toSortedListDesc()
	...

// Output: [4,3,2,1]
```

### Filters
<a name="filter" href="#filter">#</a> .**filter**(*`predicate:` action<`value:` [T](/docs#wild-card-notation)> returns boolean*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/Filter.mon  "Source")

Filter the values by the provided predicate.

```javascript
action greaterThan3(integer value) returns boolean {
	return value > 3;
}

Observable.fromValues([1,2,3,4,5,6])
	.filter(greaterThan3)
	...

// Output: 4, 5, 6
```

<a name="distinct" href="#distinct">#</a> .**distinct**() returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/Distinct.mon  "Source")

Remove all duplicate values.

Note: This requires storing every unique value and therefore care should be taken when used on long running observables. A safer alternative is [DistinctUntilChanged](#distinctuntilchanged)

```javascript
Observable.fromValues([1,2,1,2,3,2,3])
	.distinct()
	...

// Output: 1, 2, 3
```

See also: [DistinctUntilChanged](#distinctuntilchanged)

<a name="distinctuntilchanged" href="#distinctuntilchanged">#</a> .**distinctUntilChanged**() returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/Distinct.mon  "Source")

Remove all back-to-back duplicates.

```javascript
Observable.fromValues([1,1,2,2,1,2,3,3])
	.distinctUntil()
	...

// Output: 1, 2, 1, 2, 3
```

See also: [Distinct](#distinct)

<a name="distinctby" href="#distinctby">#</a> .**distinctBy**(*`getKey:` action<`value:` [T1](/docs#wild-card-notation)> returns [T2](/docs#wild-card-notation)*) returns [IObservable](#iobservable-)<[T1](/docs#wild-card-notation)> [<>](/src/rx/operators/Distinct.mon  "Source")

Remove all duplicates. 

The `getKey` action returns the value by which to measure uniqueness.

Note: This requires storing every unique value and therefore care should be taken when used on long running observables. A safer alternative is [DistinctByUntilChanged](#distinctbyuntilchanged)

```javascript
action getUniqueKey(integer value) returns integer {
	return value % 3;
}

Observable.fromValues([1,2,3,4,5,6])
	.distinctBy(getUniqueKey)
	...

// Output: 1, 2, 3
```

<a name="distinctbyuntilchanged" href="#distinctbyuntilchanged">#</a> .**distinctByUntilChanged**(*`getKey:` action<`value:` [T1](/docs#wild-card-notation)> returns [T2](/docs#wild-card-notation)*) returns [IObservable](#iobservable-)<[T1](/docs#wild-card-notation)> [<>](/src/rx/operators/Distinct.mon  "Source")

Remove all back-to-back duplicates. 

The `getKey` action returns the value by which to measure uniqueness.
```javascript
action getUniqueKey(integer value) returns integer {
	return value % 3;
}

Observable.fromValues([1,1,1,4,4,4,5,6,7,8])
	.distinctBy(getUniqueKey)
	...

// Output: 1,5,6,7,8
```

<a name="distinctbyfield" href="#distinctbyfield">#</a> .**distinctByField**(*`fieldName:` any*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/Distinct.mon  "Source")

Remove values with a duplicate `fieldName` value. 

Note: This requires storing every unique value and therefore care should be taken when used on long running observables. A safer alternative is [DistinctByFieldUntilChanged](#distinctbyfielduntilchanged)


Note: The `fieldName` can be of any type (Eg. an integer for [IObservable](#iobservable-)\<sequence> or the key type for an [IObservable](#iobservable-)\<dictionary>)
```javascript
event E {
	integer value;
}

Observable.fromValues([E(1),E(2),E(1),E(2),E(3)])
	.distinctByField("value")
	...

// Output: E(1), E(2), E(3)
```

<a name="distinctbyfielduntilchanged" href="#distinctbyfielduntilchanged">#</a> .**distinctByFieldUntilChanged**(*`fieldName:` any*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/Distinct.mon  "Source")

Remove back-to-back values with a duplicate `fieldName` value. 

Note: The `fieldName` can be of any type (Eg. an integer for [IObservable](#iobservable-)\<sequence> or the key type for an [IObservable](#iobservable-)\<dictionary>)
```javascript
event E {
	integer value;
}

Observable.fromValues([E(1),E(1),E(2),E(1),E(3)])
	.distinctByFieldUntilChanged("value")
	...

// Output: E(1), E(2), E(1), E(3)
```

<a name="take" href="#take">#</a> .**take**(*`count:` integer*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/Take.mon  "Source")

Take only the first `count` items.

```javascript
Observable.fromValues([1,2,3,4])
	.take(3)
	...

// Output: 1,2,3
```

<a name="first" href="#first">#</a> .**first**() returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/First.mon  "Source")

Take only the first item.

```javascript
Observable.fromValues([1,2,3,4])
	.first()
	...

// Output: 1
```

<a name="takelast" href="#takelast">#</a> .**takeLast**(*`count:` integer*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/TakeLast.mon  "Source")

Take only the last `count` items.

Note: The Observable must complete otherwise you won't receive a value.
```javascript
Observable.fromValues([1,2,3,4])
	.takeLast(3)
	...

// Output: 2,3,4
```

<a name="last" href="#last">#</a> .**last**() returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/Last.mon  "Source")

Take only the last item.

Note: The Observable must complete otherwise you won't receive a value.
```javascript
Observable.fromValues([1,2,3,4])
	.last()
	...

// Output: 4
```

<a name="skip" href="#skip">#</a> .**skip**(*`count:` integer*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/Skip.mon  "Source")

Skip the first `count` values.

```javascript
Observable.fromValues([1,2,3,4])
	.skip(2)
	...

// Output: 3,4
```

<a name="skiplast" href="#skiplast">#</a> .**skipLast**(*`count:` integer*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/SkipLast.mon  "Source")

Skip the last `count` values.

```javascript
Observable.fromValues([1,2,3,4])
	.skipLast(2)
	...

// Output: 1,2
```

<a name="takeuntil" href="#takeuntil">#</a> .**takeUntil**(*`trigger:` [IObservable](#iobservable-)*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/TakeUntil.mon  "Source")

Take values until the `trigger` receives a value.
```javascript
Observable.interval(0.1) // Emits an incrementing integer every 100 millis
	.takeUntil(Observable.interval(1.0))
	...

// Output: 0,1,2,3,4,5,6,7,8,9
```

<a name="takewhile" href="#takewhile">#</a> .**takeWhile**(*`predicate:` action<`value:` [T](/docs#wild-card-notation)> returns boolean*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/TakeWhile.mon  "Source")

Take until the `predicate` for a received `value` returns false.
```javascript
action isLessThan3(integer value) returns boolean {
	return values < 3;
}

Observable.fromValues([0,1,2,3,4]) // Emits an incrementing integer every 100 millis
	.takeWhile(isLessThan3)
	...

// Output: 0,1,2
```

<a name="skipuntil" href="#skipuntil">#</a> .**skipUntil**(*`trigger:` [IObservable](#iobservable-)*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/SkipUntil.mon  "Source")

Skip values until the `trigger` receives a value.
```javascript
Observable.interval(0.1) // Emits an incrementing integer every 100 millis
	.skipUntil(Observable.interval(1.0))
	...

// Output: 10,11,12,13...
```

<a name="skipwhile" href="#skipwhile">#</a> .**skipWhile**(*`predicate:` action<`value:` [T](/docs#wild-card-notation)> returns boolean*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/SkipWhile.mon  "Source")

Skip until the `predicate` for a received `value` returns false.
```javascript
action isLessThan3(integer value) returns boolean {
	return values < 3;
}

Observable.fromValues([0,1,2,3,4]) // Emits an incrementing integer every 100 millis
	.skipWhile(isLessThan3)
	...

// Output: 3,4
```

### Combiners
### Error Handling
<a name="catcherror" href="#catcherror">#</a> .**catchError**(*`substitute:`  [IObservable](#iobservable-)<[T](/docs#wild-card-notation)>*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/CatchError.mon  "Source")

Switch to an alternative data source in the event of an error.

```javascript
action someActionThatThrows(integer value) returns integer {
	throw com.apama.exceptions.Exception("Ahhhh", "RuntimeException");
}

Observable.fromValues([1,2,3,4])
	.map(someActionThatThrows)
	.catchError(Observable.fromValues(5,6,7,8))
	...

// Output: 5,6,7,8
```

<a name="retry" href="#retry">#</a> .**retry**(*`attempts:` integer*) returns [IObservable](#iobservable-)<[T](/docs#wild-card-notation)> [<>](/src/rx/operators/Retry.mon  "Source")

Reconnect to the datasource in the event of an error. At most `attempts` times.

```javascript
action sometimesThrows(integer value) returns integer {
	if (5).rand() = 0 {
		throw com.apama.exceptions.Exception("Ahhhh", "RuntimeException");
	}
	return value;
}

Observable.fromValues([1,2,3,4])
	.map(sometimesThrows)
	.retry(3)
	...

// Example Output: 1,1,2,3,1,2,3,4
// Example Output: 1,1,2,1,2,1, Exception("Ahhhh", "RuntimeException")
```
 
### Utils
### Conditional
### Math and Aggregation
