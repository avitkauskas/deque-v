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

	q = deque[int](min: -200, max: -100)
	assert q.data.len == 64
	assert q.min == 64
	assert q.max == -1

	q = deque[int](min: 200, max: 100)
	assert q.data.len == 128
	assert q.min == 128
	assert q.max == 100

	q = deque[int](min: 2_000_000_000)
	assert q.data.len == max_deque_size
	assert q.min == max_deque_size

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

fn test_max_len() {
	mut q := deque[int]()
	assert q.max_len() == -1

	q = deque[int](max: 100)
	assert q.max_len() == 100

	q = deque[int](max: -100)
	assert q.max_len() == -1
}

fn test_is_empty() {
	mut q := deque[int]()
	assert q.is_empty() == true
	q.tail++
	assert q.is_empty() == false
}

fn test_clear() {
	mut q := deque[int]()
	q.head = 1
	q.tail = 2
	q.clear()
	assert q.head == 0
	assert q.tail == 0
}

fn test_push_front() {
	mut q := deque[int](min: 8)
	assert q.data.len == 8
	q.data = [1, 2, 3, 4, 5, 6, 0, 0]
	q.head = 0
	q.tail = 6
	q.push_front(7)
	assert q.head == 7
	assert q.tail == 6
	assert q.data[q.head] == 7
	q.push_front(8)
	assert q.data.len == 16
	assert q.head == 0
	assert q.tail == 8
	assert q.data[q.head] == 8

	q = deque[int](min: 8, max: 8)
	assert q.data.len == 8
	q.data = [1, 2, 3, 4, 5, 6, 7, 0]
	q.head = 0
	q.tail = 7
	q.push_front(8)
	assert q.data.len == 16
	assert q.head == 0
	assert q.tail == 8
	assert q.data[q.head] == 8
	q.push_front(9)
	assert q.head == 15
	assert q.tail == 7
	assert q.data[q.head] == 9
	assert q.data[q.tail - 1] == 6
}

fn test_push_back() {
	mut q := deque[int](min: 8)
	assert q.data.len == 8
	q.data = [0, 1, 2, 3, 4, 5, 6, 0]
	q.head = 1
	q.tail = 7
	q.push_back(7)
	assert q.head == 1
	assert q.tail == 0
	assert q.data[7] == 7
	q.push_back(8)
	assert q.data.len == 16
	assert q.head == 0
	assert q.tail == 8
	assert q.data[q.tail - 1] == 8

	q = deque[int](min: 8, max: 8)
	assert q.data.len == 8
	q.data = [1, 2, 3, 4, 5, 6, 7, 0]
	q.head = 0
	q.tail = 7
	q.push_back(8)
	assert q.data.len == 16
	assert q.head == 0
	assert q.tail == 8
	assert q.data[q.tail - 1] == 8
	q.push_back(9)
	assert q.head == 1
	assert q.tail == 9
	assert q.data[q.head] == 2
	assert q.data[q.tail - 1] == 9
}

fn test_pop_front() {
	mut q := deque[int](min: 4)
	assert q.pop_front() == none
	q.data = [0, 1, 2, 3, 4, 0, 0, 0]
	q.head = 1
	q.tail = 5
	assert q.pop_front()? == 1
	assert q.data.len == 8
	assert q.head == 2
	assert q.tail == 5
	assert q.pop_front()? == 2
	assert q.data.len == 4
	assert q.head == 0
	assert q.tail == 2
	assert q.data[q.head] == 3
}

fn test_pop_back() {
	mut q := deque[int](min: 4)
	assert q.pop_back() == none
	q.data = [0, 1, 2, 3, 4, 0, 0, 0]
	q.head = 1
	q.tail = 5
	assert q.pop_back()? == 4
	assert q.data.len == 8
	assert q.head == 1
	assert q.tail == 4
	assert q.pop_back()? == 3
	assert q.data.len == 4
	assert q.head == 0
	assert q.tail == 2
	assert q.data[q.head] == 1
}

fn test_front_and_back() {
	mut q := deque[int](min: 4)
	assert q.front() == none
	assert q.back() == none
	q.data = [0, 1, 2, 0]
	q.head = 1
	q.tail = 3
	assert q.front()? == 1
	assert q.back()? == 2
}

fn test_get_and_set() {
	mut q := deque[int](min: 4)
	assert q.get(0) == none
	assert q.get(-1) == none
	q.data = [2, 0, 0, 1]
	q.head = 3
	q.tail = 1
	assert q.get(1)? == 2
	assert q.get(2) == none
	q.set(1, 3)!
	assert q.get(1)? == 3
	assert q.data[0] == 3
}

fn test_append() {
	mut q := deque[int](min: 4)
	q.append([1, 2, 3])
	assert q.data == [1, 2, 3, 0]
	assert q.head == 0
	assert q.tail == 3
}

fn test_prepend() {
	mut q := deque[int](min: 4)
	q.prepend([1, 2, 3])
	assert q.data == [0, 1, 2, 3]
	assert q.head == 1
	assert q.tail == 0
}

fn test_shrink() {
	mut q := deque[int](min: 256)
	q.head = 100
	q.tail = 200
	q.shrink()
	assert q.data.len == 256
	assert q.head == 100
	assert q.tail == 200

	q = deque[int](min: 8)
	q.data = [0, 0, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	assert q.data.len == 16
	q.head = 2
	q.tail = 4
	q.shrink()
	assert q.data.len == 8
	assert q.head == 0
	assert q.tail == 2
}

fn test_array() {
	mut q := deque[int](min: 8)
	assert q.array() == []
	q.data = [3, 4, 0, 0, 0, 0, 1, 2]
	q.head = 6
	q.tail = 2
	assert q.array() == [1, 2, 3, 4]
}

fn test_str() {
	mut q := deque[int]()
	assert q.str() == '[]'
	q.data = []int{len: 8, init: index}
	q.tail = 6
	assert q.str() == '[0, 1, 2, 3, 4, 5]'
	q.data = []int{len: 32, init: index}
	q.tail = 26
	assert q.str() == '[0, 1, 2, 3, 4, 5, 6, 7, 8, 9,\n... 6 other elements ...,\n16, 17, 18, 19, 20, 21, 22, 23, 24, 25]'
}
