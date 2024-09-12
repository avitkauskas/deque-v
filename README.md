# Quick double-ended queue (deque) for V

This is a V module implementing **deque** as a circular automatically growing & shrinking buffer based on generic dynamic V array `[]T`.

Ignoring the cost of internal resize actions, it supports **O(1)** time operations of **push** and **pop** at both ends of the queue as well as direct access to any element to **get** or **set** it. Any sequence of *m* *push* and *pop* operations results in a total of *O(m)* time spent during all calls to resize.

## Installation

```shell
v install avitkauskas.dq
```

## Usage

Default initialization:
```v
import avitkauskas.dq

mut q := dq.new[int]()
```

Definitions of supported functions:
```v
// push new element to the front or back of the queue
q.push_front(x T)
q.push_back(x T)

// pop (delete and return) the first or last element of the queue
q.pop_front() ?T
q.pop_back() ?T

// many functions return `none` if the queue is empty
q.pop_front() or { 0 }
q.pop_back() or { 0 }

// to use it as a single-ended queue, you can use aliases
q.push(x T) // same as q.push_back(x T)
q.pop() ?T  // same as q.pop_front() ?T

// append or predend several elements at once (given in an array)
q.append(a []T)
q.prepend(a []T)

// the order of the elements will remain unchanged
// given the queue like [1, 1, 1] and an array of [7, 8, 9],
// `append` results in a queue of [1, 1, 1, 7, 8, 9]
// and `prepend` results is [7, 8, 9, 1, 1, 1]

// to check the first or last element in the queue without removing it
q.front() ?T
q.back() ?T

// for single-ended queue you can use an alias
q.peek() ?T // same as q.front() ?T

// to get and set any individual element at any index
q.get(i int) ?T      // `none` if empty or `i` is out of range
q.set(i int, x T) !  //  error if empty or `i` is out of range

// number of elements in a queue
q.len() int

// max number of elements allowed in a queue (when max: parameter is set)
// before starting to drop the oldest elements from the other end on `push`
q.max_len() int

// check if the queue is empty
q.is_empty() bool

// clear the queue (delete all elements) but keep the buffer in memory
q.clear()

// keep all the elements in a queue but shrink the buffer
// to the size of the nearest power of two in elements count
q.shrink()

// get the array representation of the queue
q.array() []T

// get the string representation of the queue
// also called implicitly by print() and println()
q.str() string

// str() returns the string representation of the array
// if the size of the queue is less than or equal to 25 elements.
// Otherwise, gives the first 10 and the last 10 elements in a string like
// [1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
// ... 190 other elements ...,
// 201, 202, 203, 204, 205, 206, 207, 208, 209, 210]
```

## Initialization: parameters and optimization

You should find deque being quick and efficient by default for most common use cases. But if you want to further optimize for speed and know certain characteristics of your queue at run time (most likely size etc.), you can provide certain parameters during the initialization of the queue to make it run faster. Speed gain can be significant if you avoid the queue growing and shrinking as this also requires copying of the existing elements and is expensive.

### Parameters

The **new\[T\]()** initialization function accepts the following optional map of parameters:
```v
@[params]
pub struct DequeParams {
pub:
	min    int  = 64
	max    int  = -1
	shrink bool = true
}
```

The default initial size of deque is **64 elements**.
It automatically grows by doubling its size when it gets full.
And it automatically shrinks in half when the number of elements in the queue becomes a quarter (1/4) or less of its total capacity. It waits for the number of elements to drop to 1/4 of the capacity (not just below 1/2) as you do not want to start growing again immediatelly after shrinking if new elements start to arrive.

If you know that the size of your queue will grow to the certain number and should stay there for the most of the time, dropping to lower numbers just occasionally, you can provide the `min:` parameter and `new[int]()` will allocate memory for this number of elements at the time of initialization and will never shrink below it (but will grow as needed and will shrink to the `min` size if the number of elements will become less than `min/2`):
```
mut q := dq.new[int](min: 100_000)
```
Avoiding resizing (re-allocations of the underlying array and copying of the elements of the queue to the new location) you can gain a lot of speed at the expense of the higher memory usage.

If you do not know the max size of your queue in advance, but you still want to be as quick as possible - you can tell deque not to shrink at any time. Then the queue will grow as needed but will never shrink.
```v
mut q := dq.new[int](shrink: false)
```

You can combine these two parameters together, if needed:
```v
mut q := dq.new[int](min: 100_000, shrink: false)
```
This will initially allocate space for the `min` number of elements, will grow as needed, but will never shrink.

And finally, you can provide the `max:` parameter if you want your queue to be as big as that, but never bigger. In that case, if you have `max` elements in the queue already, and any new element is pushed to the front or the back of the queue, one element from the other end is automaticaly popped and lost.
```v
mut q := dq.new[int](max: 100_000)
```

## Limitations

Maximum elements allowed in deque is `2^30 - 1` = **`1_073_741_823`**. This is because of the optimizations used in the implementation (allocating memory in chunks of the power of 2 and using `bitwise and` (`&`) operator for the calculation of the cyclic indexes instead of the slower `modulus` (`%`) operator), and because of the limitation of V of keeping the number of elements of array in the signed `32-bit int` variable, therefore the next allocation of the `2^31` elements is not possible.

As a simple rule to remember, the number of elements in your queue should not ever roughly exceed **`1 billion`**. I hope that will be enough to keep most of us happy.

Let's go queuing!
