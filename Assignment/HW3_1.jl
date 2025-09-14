using Distributed
n = 5
addprocs(n)

@everywhere function work(msg, iw, workers_ids)
	println("msg=$msg")
	if iw < length(workers_ids)
		inext = iw+1
		next = workers_ids[iw+1]
		@fetchfrom next work(msg+1, inext, workers_ids)
	else
		@fetchfrom workers_ids[1] println("msg=$msg")
	end
	return nothing
end

msg = 2
iw = 1
workers_ids = workers()
@fetchfrom workers_ids[iw] work(msg, iw, workers_ids)