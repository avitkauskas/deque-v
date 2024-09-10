module dq

fn test_deque() {
	mut q := deque[int]()
	assert q.data.len == 64
	assert q.min == 64
	assert q.max == -1
	assert q.head == 0
	assert q.tail == 0
	assert q.shrink == true

	q = deque[int](min: 100)
	assert q.data.len == 128
	assert q.min == 128
	assert q.max == -1

	q = deque[int](max: 100)
	assert q.data.len == 64
	assert q.min == 64
	assert q.max == 100

	q = deque[int](min: 100, max: 200)
	assert q.data.len == 128
	assert q.min == 128
	assert q.max == 200

	q = deque[int](min: 200, max: 100)
	assert q.data.len == 128
	assert q.min == 128
	assert q.max == 100

	q = deque[int](shrink: false)
	assert q.shrink == false
}

fn test_len() {
	mut q := deque[int]()
	assert q.data.len == 64
	assert q.len() == 0

	q.head = 10
	q.tail = 20
	assert q.len() == 10

	q.head = 60
	q.tail = 10
	assert q.len() == 14
}
