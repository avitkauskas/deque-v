import dq

// mut q := dq.deque[int](min: 1_000_000_000, shrink: false)
// mut q := dq.deque[int](min: 1_000_000_000, max: 1_000_000_000)
// mut q := dq.deque[int](min: 2_000_000_000, max: 1_000_000_000)
// mut q := dq.deque[int](max: 1_000)
// mut q := dq.deque[int](min: 1_000_000_000)
// mut q := dq.deque[int](min: 500_000_000)
// mut q := dq.deque[int](max: 1_000_000_000)
// mut q := dq.deque[int](max: 1_000_000)
// mut q := dq.deque[int](shrink: false)
mut q := dq.deque[int]()

num := 1_000_000_000
max := if q.max_len() != -1 { q.max_len() } else { num }

for _ in 0 .. 2 {
	for i in 0 .. num {
		q.push_back(i)
	}
	// println(q.len())
	// println('${q.front()?}, ${q.back()?}')
	for _ in 0 .. max {
		q.pop_front()?
	}
	// println(q.len())
}
