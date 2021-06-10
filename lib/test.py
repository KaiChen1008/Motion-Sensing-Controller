class priority_queue:
    def __init__(self):
        self.entry_finder = {}
        self.pq = []
        
    def push(self, item):
        heapq.heappush(self.pq, item)
        if item in self.entry_finder:
            self.entry_finder[item] += 1
        else:
            self.entry_finder[item] = 1

    def dele(self, item):
        if self.entry_finder[item] == 1:
            del self.entry_finder[item]
        else:
            self.entry_finder[item] -= 1
        return item

    def mini(self):
        item = self.pop()
        self.push(item)
        return item

    def pop(self):
        while self.pq:
            item = heapq.heappop(self.pq)
            if item in self.entry_finder:
                self.dele(item)
                return item