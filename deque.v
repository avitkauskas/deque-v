module dq

const max_str_elements = 20

struct Deque[T] {
	min int
mut:
	data []T
	j    i64
	n    i64
}

enum Scale {
	up
	down
}

@[params]
pub struct DequeParams {
pub:
	min int = 64
}

pub fn deque[T](params DequeParams) Deque[T] {
	return Deque[T]{
		data: []T{len: params.min}
		min:  params.min
	}
}

pub fn (q &Deque[T]) size() int {
	return int(q.n)
}

pub fn (q &Deque[T]) empty() bool {
	return q.n == 0
}

pub fn (mut q Deque[T]) clear() {
	q.data = []T{len: q.min}
	q.j = 0
	q.n = 0
}

@[direct_array_access]
pub fn (q &Deque[T]) array() []T {
	mut a := []T{len: int(q.n)}
	for i := 0; i < q.n; i++ {
		a[i] = q.data[(q.j + i) % q.data.len]
	}
	return a
}

@[direct_array_access]
pub fn (mut q Deque[T]) push_front[T](x T) {
	if q.n + 1 > q.data.len {
		q.resize(Scale.up)
	}
	q.j = (q.j - 1 + q.data.len) % q.data.len
	q.data[q.j] = x
	q.n++
}

@[direct_array_access]
pub fn (mut q Deque[T]) push_back[T](x T) {
	if q.n + 1 > q.data.len {
		q.resize(Scale.up)
	}
	q.data[(q.j + q.n) % q.data.len] = x
	q.n++
}

pub fn (mut q Deque[T]) push[T](x T) {
	q.push_back(x)
}

@[direct_array_access]
pub fn (mut q Deque[T]) pop_front[T]() ?T {
	if q.n == 0 {
		return none
	}
	x := q.data[q.j]
	q.j = (q.j + 1) % q.data.len
	q.n--
	if q.data.len > q.min && q.data.len >= 4 * q.n {
		q.resize(Scale.down)
	}
	return x
}

@[direct_array_access]
pub fn (mut q Deque[T]) pop_back[T]() ?T {
	if q.n == 0 {
		return none
	}
	x := q.data[(q.j + q.n - 1) % q.data.len]
	q.n--
	if q.data.len > q.min && q.data.len >= 4 * q.n {
		q.resize(Scale.down)
	}
	return x
}

pub fn (mut q Deque[T]) pop[T]() ?T {
	return q.pop_front()
}

@[direct_array_access]
pub fn (q &Deque[T]) front[T]() ?T {
	if q.n == 0 {
		return none
	}
	return q.data[q.j]
}

@[direct_array_access]
pub fn (q &Deque[T]) back[T]() ?T {
	if q.n == 0 {
		return none
	}
	return q.data[(q.j + q.n - 1) % q.data.len]
}

@[direct_array_access]
pub fn (q &Deque[T]) get[T](i int) ?T {
	if q.n == 0 || i < 0 || i >= q.n {
		return none
	}
	return q.data[(q.j + i) % q.data.len]
}

@[direct_array_access]
pub fn (mut q Deque[T]) put[T](i int, x T) ! {
	if q.n == 0 || i < 0 || i >= q.n {
		return error('dq.put(): put was attempted on an empty queue')
	}
	q.data[(q.j + i) % q.data.len] = x
}

pub fn (q &Deque[T]) str() string {
	if q.n <= dq.max_str_elements + 5 {
		return q.array().str()
	}
	len := dq.max_str_elements / 2
	mut head := []T{len: len}
	mut tail := []T{len: len}
	for i := 0; i < len; i++ {
		head[i] = q.data[(q.j + i) % q.data.len]
	}
	for i := q.n - len; i < q.n; i++ {
		tail[i] = q.data[(q.j + i) % q.data.len]
	}
	head_str := head.str()
	tail_str := tail.str()
	return '${head_str[..head_str.len - 1]}, ..., ..., ...,\n${tail_str[1..]}'
}

@[direct_array_access]
fn (mut q Deque[T]) resize[T](scale Scale) {
	mut size := i64(0)
	match scale {
		.up {
			if q.data.len == max_i32 {
				panic('dq.resize(): queue exceeded max V array size of max_i32 = ${max_i32}')
			}
			size = i64(q.data.len) * 2
			if size > max_i32 {
				size = max_i32
			}
		}
		.down {
			if q.data.len == max_i32 {
				size = max_i32 / 2 + 1
			} else {
				size = q.data.len / 2
				if size < q.min {
					size = q.min
				}
			}
		}
	}
	mut a := []T{len: int(size)}
	unsafe {
		len1 := q.data.len - q.j
		len2 := q.j + q.n - q.data.len
		if len1 > q.n {
			len1 = q.n
			len2 = 0
		}
		vmemcpy(&a[0], &q.data[q.j], isize(len1) * q.data.element_size)
		vmemcpy(&a[len1], &q.data[0], isize(len2) * q.data.element_size)
	}
	// unsafe block above does the following:
	// for i := 0; i < q.n; i++ {
	// 	a[i] = q.data[(q.j + i) % q.data.len]
	// }
	q.data = a
	q.j = 0
}
