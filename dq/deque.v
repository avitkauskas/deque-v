module dq

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
	min    int  = dq.default_deque_size
	max    int  = -1
	shrink bool = true
}

pub fn deque[T](params DequeParams) Deque[T] {
	par_min := if params.min > dq.max_deque_size { dq.max_deque_size } else { params.min }
	mut cap := 1
	for cap < par_min {
		cap *= 2
	}

	mut par_max := if params.max > dq.max_deque_size { dq.max_deque_size } else { params.max }
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
		return error('dq.set(): set was attempted on an empty queue')
	}
	q.data[(q.head + i) & (q.data.len - 1)] = x
}

// @[direct_array_access]
// pub fn (q &Deque[T]) array() []T {
// 	mut a := []T{len: int(q.n)}
// 	for i := 0; i < q.n; i++ {
// 		a[i] = q.data[(q.j + i) % q.data.len]
// 	}
// 	return a
// }

// pub fn (q &Deque[T]) str() string {
// 	if q.n <= dq.max_str_elements + 5 {
// 		return q.array().str()
// 	}
// 	len := dq.max_str_elements / 2
// 	mut head := []T{len: len}
// 	mut tail := []T{len: len}
// 	for i := 0; i < len; i++ {
// 		head[i] = q.data[(q.j + i) % q.data.len]
// 	}
// 	for i := q.n - len; i < q.n; i++ {
// 		tail[i] = q.data[(q.j + i) % q.data.len]
// 	}
// 	head_str := head.str()
// 	tail_str := tail.str()
// 	return '${head_str[..head_str.len - 1]}, ..., ..., ...,\n${tail_str[1..]}'
// }

@[direct_array_access]
fn (mut q Deque[T]) resize(scale Scale) {
	match scale {
		.up {
			if q.data.len == dq.max_deque_size {
				panic('dq.resize(): deque exceeded the maximum allowed size of ${dq.max_deque_size - 1}')
			}
			p := q.head
			n := q.data.len
			r := n - p

			new_cap := n * 2
			mut new_arr := []T{len: new_cap}

			for i in 0 .. r {
				new_arr[i] = q.data[p + i]
			}
			for i in 0 .. p {
				new_arr[r + i] = q.data[i]
			}

			q.data = new_arr
			q.head = 0
			q.tail = n
		}
		.down {
			h := q.head
			mut p := q.tail
			n := q.data.len
			mut r := n - h
			l := q.len()
			if r > l {
				r = l
				p = 0
			}

			new_cap := q.data.len / 2
			mut new_arr := []T{len: new_cap}

			for i in 0 .. r {
				new_arr[i] = q.data[h + i]
			}
			for i in 0 .. p {
				new_arr[r + i] = q.data[i]
			}

			q.data = new_arr
			q.head = 0
			q.tail = l
		}
	}
}

// @[direct_array_access]
// fn (mut q Deque[T]) resize[T](scale Scale) {
// 	mut size := i64(0)
// 	match scale {
// 		.up {
// 			if q.data.len == max_i32 {
// 				panic('dq.resize(): queue exceeded max V array size of max_i32 = ${max_i32}')
// 			}
// 			size = i64(q.data.len) * 2
// 			if size > max_i32 {
// 				size = max_i32
// 			}
// 		}
// 		.down {
// 			if q.data.len == max_i32 {
// 				size = max_i32 / 2 + 1
// 			} else {
// 				size = q.data.len / 2
// 				if size < q.min {
// 					size = q.min
// 				}
// 			}
// 		}
// 	}
// 	mut a := []T{len: int(size)}
// 	unsafe {
// 		len1 := q.data.len - q.j
// 		len2 := q.j + q.n - q.data.len
// 		if len1 > q.n {
// 			len1 = q.n
// 			len2 = 0
// 		}
// 		vmemcpy(&a[0], &q.data[q.j], isize(len1) * q.data.element_size)
// 		vmemcpy(&a[len1], &q.data[0], isize(len2) * q.data.element_size)
// 	}
// 	// unsafe block above does the following:
// 	// for i := 0; i < q.n; i++ {
// 	// 	a[i] = q.data[(q.j + i) % q.data.len]
// 	// }
// 	q.data = a
// 	q.j = 0
// }
