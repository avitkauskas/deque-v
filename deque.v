module deque

const default_deque_size = 64
const max_deque_size = max_int / 2 + 1
const max_str_elements = 20

enum Scale {
	up
	down
}

struct Deque[T] {
	min    int
	max    int
	shrink bool
mut:
	data []T
	head int
	tail int
}

@[params]
pub struct DequeParams {
pub:
	min    int  = deque.default_deque_size
	max    int  = -1
	shrink bool = true
}

pub fn new[T](params DequeParams) Deque[T] {
	mut par_min := if params.min > deque.max_deque_size { deque.max_deque_size } else { params.min }
	if par_min <= 0 {
		par_min = deque.default_deque_size
	}
	mut cap := 1
	for cap < par_min {
		cap *= 2
	}

	mut par_max := if params.max > deque.max_deque_size { deque.max_deque_size } else { params.max }
	if par_max > 0 {
		mut max := 1
		for max < par_max {
			max *= 2
		}
		if max < cap {
			cap = max
		}
	} else {
		par_max = -1
	}

	return Deque[T]{
		data:   []T{len: cap}
		min:    cap
		max:    par_max
		shrink: params.shrink
	}
}

pub fn (q &Deque[T]) len() int {
	return (q.tail - q.head) & (q.data.len - 1)
}

pub fn (q &Deque[T]) max_len() int {
	return q.max
}

pub fn (q &Deque[T]) is_empty() bool {
	return q.head == q.tail
}

pub fn (mut q Deque[T]) clear() {
	q.head = 0
	q.tail = 0
}

@[direct_array_access]
pub fn (mut q Deque[T]) push_front(x T) {
	q.head = (q.head - 1) & (q.data.len - 1)
	q.data[q.head] = x
	if q.max > 0 && q.len() > q.max {
		q.pop_back() or { T{} }
	}
	if q.head == q.tail {
		q.resize(Scale.up)
	}
}

@[direct_array_access]
pub fn (mut q Deque[T]) push_back(x T) {
	q.data[q.tail] = x
	q.tail = (q.tail + 1) & (q.data.len - 1)
	if q.max > 0 && q.len() > q.max {
		q.pop_front() or { T{} }
	}
	if q.head == q.tail {
		q.resize(Scale.up)
	}
}

pub fn (mut q Deque[T]) push(x T) {
	q.push_back(x)
}

pub fn (mut q Deque[T]) append(a []T) {
	for e in a {
		q.push_back(e)
	}
}

@[direct_array_access]
pub fn (mut q Deque[T]) prepend(a []T) {
	for i := a.len - 1; i >= 0; i-- {
		q.push_front(a[i])
	}
}

@[direct_array_access]
pub fn (mut q Deque[T]) pop_front() ?T {
	if q.head == q.tail {
		return none
	}
	res := q.data[q.head]
	q.head = (q.head + 1) & (q.data.len - 1)

	if q.shrink && q.data.len > q.min && q.data.len >= i64(4) * q.len() {
		q.resize(Scale.down)
	}

	return res
}

@[direct_array_access]
pub fn (mut q Deque[T]) pop_back() ?T {
	if q.head == q.tail {
		return none
	}
	q.tail = (q.tail - 1) & (q.data.len - 1)
	res := q.data[q.tail]

	if q.shrink && q.data.len > q.min && q.data.len >= i64(4) * q.len() {
		q.resize(Scale.down)
	}

	return res
}

pub fn (mut q Deque[T]) pop() ?T {
	return q.pop_front()
}

@[direct_array_access]
pub fn (q &Deque[T]) front() ?T {
	if q.head == q.tail {
		return none
	}
	return q.data[q.head]
}

pub fn (q &Deque[T]) peek() ?T {
	return q.front()
}

@[direct_array_access]
pub fn (q &Deque[T]) back() ?T {
	if q.head == q.tail {
		return none
	}
	return q.data[(q.tail - 1) & (q.data.len - 1)]
}

@[direct_array_access]
pub fn (q &Deque[T]) get(i int) ?T {
	if q.head == q.tail || i < 0 || i >= q.len() {
		return none
	}
	return q.data[(q.head + i) & (q.data.len - 1)]
}

@[direct_array_access]
pub fn (mut q Deque[T]) set(i int, x T) ! {
	if q.head == q.tail || i < 0 || i >= q.len() {
		return error('deque.set(): set was attempted on an empty queue')
	}
	q.data[(q.head + i) & (q.data.len - 1)] = x
}

pub fn (mut q Deque[T]) shrink() {
	if q.data.len <= q.min {
		return
	}
	q_len := q.len()
	mut new_cap := q.min
	for new_cap < q_len {
		new_cap *= 2
	}

	mut new_arr := []T{len: new_cap}

	mut tail_len := q.tail
	mut head_len := q.data.len - q.head
	if head_len > q_len {
		head_len = q_len
		tail_len = 0
	}

	for i in 0 .. head_len {
		new_arr[i] = q.data[q.head + i]
	}
	for i in 0 .. tail_len {
		new_arr[head_len + i] = q.data[i]
	}

	q.head = 0
	q.tail = q_len
	q.data = new_arr
}

@[direct_array_access]
pub fn (q &Deque[T]) array() []T {
	len := q.len()
	mut a := []T{len: len}
	for i in 0 .. len {
		a[i] = q.data[(q.head + i) & (q.data.len - 1)]
	}
	return a
}

@[direct_array_access]
pub fn (q &Deque[T]) str() string {
	q_len := q.len()
	if q_len <= deque.max_str_elements + 5 {
		return q.array().str()
	}
	len := deque.max_str_elements / 2
	mut head := []T{len: len}
	mut tail := []T{len: len}
	for i in 0 .. len {
		head[i] = q.data[(q.head + i) & (q.data.len - 1)]
	}
	for i in 0 .. len {
		tail[i] = q.data[(q.tail - len + i) & (q.data.len - 1)]
	}
	head_str := head.str()
	tail_str := tail.str()
	return '${head_str[..head_str.len - 1]},\n... ${q_len - deque.max_str_elements} other elements ...,\n${tail_str[1..]}'
}

@[direct_array_access]
fn (mut q Deque[T]) resize(scale Scale) {
	match scale {
		.up {
			if q.data.len == deque.max_deque_size {
				panic('deque.resize(): deque exceeded the maximum allowed size of ${deque.max_deque_size - 1}')
			}

			tail_len := q.tail
			head_len := q.data.len - tail_len

			new_cap := q.data.len * 2
			mut new_arr := []T{len: new_cap}

			for i in 0 .. head_len {
				new_arr[i] = q.data[q.head + i]
			}
			for i in 0 .. tail_len {
				new_arr[head_len + i] = q.data[i]
			}

			q.head = 0
			q.tail = q.data.len
			q.data = new_arr
		}
		.down {
			deque_len := q.len()
			mut tail_len := q.tail
			mut head_len := q.data.len - q.head
			if head_len > deque_len {
				head_len = deque_len
				tail_len = 0
			}

			new_cap := q.data.len / 2
			mut new_arr := []T{len: new_cap}

			for i in 0 .. head_len {
				new_arr[i] = q.data[q.head + i]
			}
			for i in 0 .. tail_len {
				new_arr[head_len + i] = q.data[i]
			}

			q.head = 0
			q.tail = deque_len
			q.data = new_arr
		}
	}
}
