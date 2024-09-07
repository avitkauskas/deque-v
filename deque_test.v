module dq

fn test_deque_default() {
	q := deque[int]()
	assert q.data.len == default_size
	assert q.min == default_size
	assert q.j == 0
	assert q.n == 0
}

fn test_deque_with_min() {
	min_size := 128
	q := deque[int](min: min_size)
	assert q.data.len == min_size
	assert q.min == min_size
	assert q.j == 0
	assert q.n == 0
}

struct AA {
	a int
	b i64
}

fn test_deque_cutom_type() {
	mut q := deque[AA]()
	a := AA{}
	q.push(a)
	assert q.pop()? == a
}

fn test_resize() {
	mut q := deque[int]()
	assert q.data.len == default_size
	q.resize(Scale.up)
	assert q.data.len == default_size * 2
	q.resize(Scale.down)
	assert q.data.len == default_size

	for i in 0 .. (default_size + 1) {
		q.push_back(i)
	}
	for _ in 0 .. 10 {
		q.pop_front()?
	}
	for i in 0 .. 5 {
		q.push_front(i)
	}
	for _ in 0 .. 5 {
		q.pop_back()?
	}

	assert q.data.len == default_size * 2
	assert q.j != 0
	assert q.n == default_size + 1 - 10

	q.resize(Scale.up)
	assert q.data.len == default_size * 4
	assert q.j == 0
	assert q.n == default_size + 1 - 10

	q.resize(Scale.down)
	assert q.data.len == default_size * 2
	assert q.j == 0
	assert q.n == default_size + 1 - 10
}

fn test_resize_big() {
	mut q := deque[int](min: 536870912)
	assert q.data.len == 536870912

	q.resize(Scale.up)
	assert q.data.len == 536870912 * 2
	assert q.n == 0
	assert q.j == 0
}

fn test_size() {
	mut q := deque[int]()
	assert q.size() == 0
	q.push(1)
	assert q.size() == 1
	q.pop()?
	assert q.size() == 0
}

fn test_empty() {
	mut q := deque[int]()
	assert q.empty() == true
	q.push(1)
	assert q.empty() == false
	q.pop()?
	assert q.empty() == true
}

fn test_clear() {
	mut q := deque[int]()
	for i in 0 .. (default_size + 1) {
		q.push(i)
	}
	q.pop()?
	assert q.data.len > default_size
	assert q.j > 0
	assert q.n > 0
	q.clear()
	assert q.data.len == default_size
	assert q.j == 0
	assert q.n == 0

	q = deque[int](min: 32)
	q.clear()
	assert q.data.len == 32
}

fn test_array() {
	mut q := deque[int]()
	for i in 0 .. (default_size + 1) {
		q.push(i)
	}
	q.pop()?
	a1 := []int{len: default_size, init: index + 1}
	a2 := q.array()
	assert a1 == a2
}

fn test_push_front() {
	mut q := deque[int]()
	q.push_front(1)
	assert q.front()? == 1
	assert q.n == 1
	q.push_front(2)
	assert q.front()? == 2
	assert q.n == 2
}

fn test_push_back() {
	mut q := deque[int]()
	q.push_back(1)
	assert q.back()? == 1
	assert q.n == 1
	q.push_back(2)
	assert q.back()? == 2
	assert q.n == 2
}

fn test_pop_front() {
	mut q := deque[int]()
	mut x := q.pop_front() or { 3 }
	assert x == 3
	q.push_front(1)
	q.push_front(2)
	x = q.pop_front()?
	assert x == 2
	assert q.n == 1
	x = q.pop_front()?
	assert x == 1
	assert q.n == 0
}

fn test_pop_back() {
	mut q := deque[int]()
	mut x := q.pop_back() or { 3 }
	assert x == 3
	q.push_back(1)
	q.push_back(2)
	x = q.pop_back()?
	assert x == 2
	assert q.n == 1
	x = q.pop_back()?
	assert x == 1
	assert q.n == 0
}

fn test_front_and_back() {
	mut q := deque[int]()
	mut f := q.front() or { 3 }
	assert f == 3
	mut b := q.back() or { 3 }
	assert b == 3
	q.push_front(1)
	q.push_back(2)
	f = q.front()?
	assert f == 1
	b = q.back()?
	assert b == 2
	assert q.n == 2
}

fn test_many_functions() {
	mut q := deque[int]()
	assert q.empty() == true

	for i in 0 .. (default_size + 1) {
		q.push_back(i)
	}
	for _ in 0 .. 10 {
		q.pop_front()?
	}
	for i in 0 .. 5 {
		q.push_front(i)
	}
	for _ in 0 .. 5 {
		q.pop_back()?
	}

	assert q.empty() == false
	assert q.j == 5
	assert q.size() == default_size + 1 - 10
	assert q.front()? == 4
	assert q.pop_front()? == 4
	assert q.front()? == 3
	assert q.back()? == 59
	assert q.pop_back()? == 59
	assert q.back()? == 58
	assert q.str().starts_with('[3, 2')
	assert q.str().ends_with('57, 58]')
	assert q.size() == default_size + 1 - 12
	assert q.get(1)? == 2
	q.put(1, 8)!
	assert q.get(1)? == 8
	q.clear()
	assert q.size() == 0
	assert q.data.len == default_size
}
