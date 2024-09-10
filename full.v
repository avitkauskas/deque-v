import dq

mut q := dq.deque[int](min: 1_000_000_000, shrink: false)

n := 1_000_000_000

for _ in 0 .. 3 {
	for i in 0 .. n {
		q.push_back(i)
	}
	for _ in 0 .. n {
		q.pop_front()?
	}
}
